# config.ini

[pynetinstall]
plugin=dvt:DVTPlugin
ros_version=7.11
default_config=config.rsc

# dvt.py:

from urllib.parse import quote

class DVTPlugin:
    def __init__(self, config):
        self.ros_version = config["pynetinstall"]["ros_version"]
        self.default_config = config["pynetinstall"]["default_config"]

    def get_files(self, info):
        mac = info.mac.hex(':').upper()
        model = quote(info.model)
        arch = info.arch

        firmware = f"https://download.mikrotik.com/routeros/{self.ros_version}/routeros-{self.ros_version}-{arch}.npk"

        return firmware, self.default_config



        docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest



        services:
 QZW.ÍÍQW">portainer-ce:
        ports:
            - 8000:8000
            - 9443:9443
        container_name: portainer
        restart: always
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - portainer_data:/dataWSqw  2aX 