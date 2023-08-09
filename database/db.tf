resource "google_compute_address" "database" {
  name = "database"
  region = "us-west1"
}

module "instance_template" {
  source  = "../.terraform/modules/vm/modules/instance_template"
  region                = "us-west1"
  project_id            = "sunlit-almanac-392511"
  # subnetwork            = var.private_subnet
  network               = "default"
  machine_type = "f1-micro"
  service_account       = ({
    email = "devopsproject@sunlit-almanac-392511.iam.gserviceaccount.com"
    scopes = ["cloud-platform"] 
})
  source_image          = "windows-server-2022-dc-v20230712"
  source_image_family   = "windows-2022"
  source_image_project  = "windows-cloud"
  # startup_script        =  file("startscript.sh")
  tags                  = ["http-server", "https-server", "jenkins-8080"]
  access_config = [{
    nat_ip  = "${google_compute_address.database.address}"
    network_tier = "PREMIUM"
  }, ]

}

module "compute_instance" {
  source  = "../.terraform/modules/vm/modules/compute_instance"
  instance_template = module.instance_template.self_link
  region = "us-west1"
  hostname = "database-vm"
  num_instances = "1"
    access_config = [{
    nat_ip  = "${google_compute_address.database.address}"
    network_tier = "PREMIUM"
  }, ]

}



