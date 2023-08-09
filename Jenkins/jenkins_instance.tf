
module "instance_template" {
  source  = "../.terraform/modules/vm/modules/instance_template"
  region                = "us-east1"
  project_id            = "sunlit-almanac-392511"
  subnetwork            = "private"
  service_account       = ({
    email = "devopsproject@sunlit-almanac-392511.iam.gserviceaccount.com"
    scopes = ["cloud-platform"] 
})
  source_image          = "windows-server-2022-dc-v20230712"
  source_image_family   = "windows-2022"
  source_image_project  = "windows-cloud"
  # startup_script        =  file("startscript.sh")
  tags                  = ["http-server", "https-server", "jenkins-8080"]
}

module "compute_instance" {
  source  = "../.terraform/modules/vm/modules/compute_instance"
  instance_template = module.instance_template.self_link
  region = "us-east1"
  hostname = "jenkins-vm"
  num_instances = "1"
  access_config = [{
    nat_ip  = "${google_compute_address.jenkins.address}"
    network_tier = "PREMIUM"
  }]

}

resource "google_compute_address" "jenkins" {
  name     = "jenkins"
  region   = "us-east1"
  subnetwork  = "private"
  address_type = "INTERNAL"
  address      = "10.0.2.40"

}


module "firewall_rules" {
  source       = "../.terraform/modules/network/modules/firewall-rules"
  project_id   = "sunlit-almanac-392511"
  network_name = "main"

  rules = [{
    name                    = "jenkins-8080"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["jenkins-8080"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["8080"]
    }]
    deny = []
  }]
}