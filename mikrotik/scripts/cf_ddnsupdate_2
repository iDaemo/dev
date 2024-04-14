# Prerequisites
# - A Cloudflare account and a domain managed by Cloudflare.
# - The Zone ID of your domain in Cloudflare. You can find this in the Cloudflare dashboard under your domain's overview tab.
# - An API token with permissions to edit DNS records. You can create this in the Cloudflare dashboard under "My Profile" > "API Tokens".

# Creating an API Token in Cloudflare
# - Go to Cloudflare Dashboard > My Profile > API Tokens.
# - Click "Create Token".
# - Use the "Edit zone DNS" template.
# - Set permissions for the specific zone (domain) you wish to update via DDNS.
# - Save and note down the API token.

# Fetching the Record ID from Cloudflare
# - Run the following after replacing <apiToken> and <dnsRecord>
    curl -X GET "https://api.cloudflare.com/client/v4/zones/<Your_Zone_ID>/dns_records?type=A&name=<dnsRecord>" \
     -H "Authorization: Bearer <apiToken>" \
     -H "Content-Type: application/json"
# - Look for the id: value in the JSON that is returned.

:local apiToken "<snip>"
:local zoneId "<snip>"
:local dnsRecord "<snip.snip.snip>"
:local wanInterface "<snip-snip>"
:local dnsRecordId "<snip>"

# Fetch the current WAN IP address
:local newIp [/ip address get [find interface=$wanInterface] address];
:set newIp [:pick $newIp 0 ([:len $newIp] -3)];
:log info ("DDNS Update: Current WAN IP is " . $newIp);

# Resolve the current DNS record IP to check if update is needed
:local currentIp [[:resolve "$dnsRecord"]];
:log info ("DDNS Update: Current DNS IP for $dnsRecord is " . $currentIp);

# Compare and update if different
:if ($newIp != $currentIp) do={
    :log info "DDNS Update: IP change detected, updating Cloudflare DNS record...";
    
    # Perform the update
    :log info "DDNS Update: Sending update request to Cloudflare...";
    /tool fetch url="https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$dnsRecordId" \
    http-method=put \
    http-header-field=("authorization: Bearer " . $apiToken . ", content-type: application/json") \
    http-data=("{\"type\":\"A\",\"name\":\"" . $dnsRecord . "\",\"content\":\"" . $newIp . "\",\"ttl\":1,\"proxied\":false}") \
    mode=https \
    dst-path="/disk/cloudflare-update-response.json";
    
    :delay 5s; # Give some time for the operation to complete and the response to be written
    
    # Check if the file exists and has content
    :if ([:len [/file find name="/disk/cloudflare-update-response.json"]] > 0) do={
        :local fileSize [/file get [/file find name="/disk/cloudflare-update-response.json"] size];
        :if ($fileSize > 0) do={
            :local updateResponse [/file get [/file find name="/disk/cloudflare-update-response.json"] contents];
            :log info ("DDNS Update: Cloudflare DNS update response: " . $updateResponse);
        } else={
            :log error "DDNS Update: Cloudflare response file is empty.";
        }
    } else={
        :log error "DDNS Update: Failed to fetch update response from Cloudflare.";
    }
} else={
    :log info "DDNS Update: No update necessary."
}