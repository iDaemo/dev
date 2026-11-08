// ==============================================================================
// SonosLibra - Site Inventory Webhook (Google Apps Script) v3.2
// ใช้คู่กับ Setup-SiteNode.ps1 v5.3
//
// v3.2:
//   - ใช้ LockService กันเลขลำดับซ้ำ เมื่อติดตั้งหลายเครื่องพร้อมกัน
//   - "จองเลข" ตอน getNext ด้วยการเพิ่มแถว RESERVED ทันที
//     แล้วเมื่อติดตั้งเสร็จจะเขียนข้อมูลจริงทับแถวที่จองไว้
//   - รันสคริปต์ซ้ำบนเครื่องเดิม (Serial เดิม) จะได้เลขที่จองไว้เดิม ไม่จองเพิ่ม
//
// วิธีอัปเดต (URL เดิมต้องไม่เปลี่ยน):
//   Deploy > Manage deployments > ไอคอนดินสอ (Edit) > Version: New version > Deploy
//   ห้ามกด "New deployment" เพราะจะได้ URL ใหม่ และสคริปต์บน USB จะเรียกไม่เจอ
// ==============================================================================

const SHEET_ID     = '1qsB5OglLGuHMBhPY2zWF445ehWtwPKTDLRB0uITrKBA';
const RESERVED_TAG = 'RESERVED';
const LOCK_WAIT_MS = 15000;

// คอลัมน์ (เริ่มที่ 1)
const COL_SITE   = 2;  // Site Name
const COL_WIN    = 3;  // Windows Name
const COL_SERIAL = 6;  // Serial Number
const NUM_COLS   = 8;

function initSheet() {
  var ss = SpreadsheetApp.openById(SHEET_ID);
  var sheet = ss.getSheets()[0];
  var headers = [
    "Timestamp",
    "Site Name",
    "Windows Name (15 Chars)",
    "Tailscale IP",
    "RustDesk ID",
    "Serial Number",
    "MAC Address",
    "Public IP"
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight("bold").setBackground("#d9ead3");
  sheet.setFrozenRows(1);
}

function jsonOut(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}

function pad2(n) {
  return n < 10 ? "0" + n : String(n);
}

// อ่านข้อมูลทุกแถว (ไม่รวมหัวตาราง)
function readRows(sheet) {
  var lastRow = sheet.getLastRow();
  if (lastRow <= 1) return [];
  return sheet.getRange(2, 1, lastRow - 1, NUM_COLS).getValues();
}

// เลขลำดับถัดไปของปีนั้น (นับรวมแถว RESERVED ด้วย จึงไม่ซ้ำกับที่จองไว้)
function getNextSequence(rows, year) {
  var maxNum = 0;
  var regex = new RegExp("^" + year + "-(\\d{2,3})-");
  for (var i = 0; i < rows.length; i++) {
    var match = String(rows[i][COL_SITE - 1]).trim().match(regex);
    if (match) {
      var num = parseInt(match[1], 10);
      if (num > maxNum) maxNum = num;
    }
  }
  return pad2(maxNum + 1);
}

// หาแถวที่จองไว้: ตาม Serial (ถ้ามี) หรือตาม prefix "YYYY-NN-"  คืนค่าเลขแถวในชีต หรือ -1
function findReservedRow(rows, opts) {
  for (var i = 0; i < rows.length; i++) {
    if (String(rows[i][COL_WIN - 1]) !== RESERVED_TAG) continue;
    var site = String(rows[i][COL_SITE - 1]);
    if (opts.serial && String(rows[i][COL_SERIAL - 1]) === opts.serial && (!opts.year || site.indexOf(opts.year + "-") === 0)) {
      return i + 2;
    }
    if (opts.prefix && site.indexOf(opts.prefix) === 0) {
      return i + 2;
    }
  }
  return -1;
}

function doGet(e) {
  var p = (e && e.parameter) ? e.parameter : {};
  var lock = LockService.getScriptLock();

  try {
    var ss = SpreadsheetApp.openById(SHEET_ID);
    var sheet = ss.getSheets()[0];

    if (sheet.getRange(1, 1).getValue() !== "Timestamp") {
      initSheet();
    }

    // --------------------------------------------------------------------------
    // 1. ขอเลขลำดับถัดไป + จองไว้ทันที
    // --------------------------------------------------------------------------
    if (p.action === "getNext") {
      var year   = p.year || new Date().getFullYear().toString();
      var serial = (p.serial || "").trim();

      lock.waitLock(LOCK_WAIT_MS);
      var rows = readRows(sheet);

      // เครื่องเดิมรันซ้ำ -> คืนเลขที่จองไว้เดิม
      if (serial) {
        var existing = findReservedRow(rows, { serial: serial, year: year });
        if (existing > 0) {
          var m = String(sheet.getRange(existing, COL_SITE).getValue()).match(/^\d{4}-(\d{2,3})-/);
          if (m) {
            return jsonOut({ status: "ready", year: year, nextSeq: m[1], reserved: true, reused: true });
          }
        }
      }

      var nextSeq = getNextSequence(rows, year);
      sheet.appendRow([
        new Date(),
        year + "-" + nextSeq + "-" + RESERVED_TAG,
        RESERVED_TAG,
        "", "",
        serial,
        "", ""
      ]);
      SpreadsheetApp.flush();
      return jsonOut({ status: "ready", year: year, nextSeq: nextSeq, reserved: true });
    }

    // --------------------------------------------------------------------------
    // 2. บันทึกข้อมูลเครื่อง (เขียนทับแถวที่จองไว้ ถ้าไม่มีให้เพิ่มแถวใหม่)
    // --------------------------------------------------------------------------
    if (p.SiteName) {
      var record = [
        new Date(),
        p.SiteName || "N/A",
        p.WinComputerName || "N/A",
        p.TailscaleIP || "N/A",
        p.RustDeskID || "N/A",
        p.SerialNumber || "N/A",
        p.MacAddress || "N/A",
        p.PublicIP || "N/A"
      ];

      lock.waitLock(LOCK_WAIT_MS);
      var rows2 = readRows(sheet);
      var prefixMatch = String(p.SiteName).match(/^(\d{4}-\d{2,3}-)/);
      var target = -1;
      if (prefixMatch) {
        target = findReservedRow(rows2, { prefix: prefixMatch[1] });
      }

      if (target > 0) {
        sheet.getRange(target, 1, 1, NUM_COLS).setValues([record]);
      } else {
        sheet.appendRow(record);   // กรณีพิมพ์เลขเอง / ติดตั้งทดแทน
      }
      SpreadsheetApp.flush();
      return jsonOut({ status: "success", site: p.SiteName, updatedReserved: target > 0 });
    }

    return jsonOut({ status: "online", version: "v3.2", received_params: p });

  } catch (err) {
    return jsonOut({ status: "error", message: err.toString() });
  } finally {
    try { lock.releaseLock(); } catch (ignore) {}
  }
}
