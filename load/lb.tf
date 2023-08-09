

# resource "google_compute_address" "windows2" {
#   name = "windows2"
#   region = "us-east1"
#   # network = "main8"
#   # subnetwork = "public8"
# }

module "vpc" {
   source  = "../.terraform/modules/network/modules/vpc"

  project_id   = "sunlit-almanac-392511"
  network_name = "main"
  routing_mode = "REGIONAL"

  delete_default_internet_gateway_routes = "true"

}


module "subnet" {
  source                                 = "../.terraform/modules/network/modules/subnets"
  project_id                             = "sunlit-almanac-392511"
  network_name                           = module.vpc.network_name
  subnets = [
     {
      subnet_name           = "private"
      subnet_ip             = "10.0.2.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    },
    {
      subnet_name           = "public"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    }]
}

# resource "google_compute_address" "windows1" {
#   name = "windows1"
#   region = "us-east1"
#   # network = "main"
#   # subnetwork = "public"
#   # address      = "10.0.42.42"
# }

module "instance_template" {
  source  = "../.terraform/modules/vm/modules/instance_template"
  machine_type = "f1-micro"
  network = "main"
  subnetwork = "public"
  project_id = "sunlit-almanac-392511"
  region = "us-east1"
  # name_prefix = "windows"
  source_image = "windows-server-2022-dc-v20230712"
  source_image_family = "windows-2022"
  source_image_project = "windows-cloud"
  service_account = ({
    email = "devopsproject@sunlit-almanac-392511.iam.gserviceaccount.com"
    scopes = ["cloud-platform"] 
})
  access_config = [{
    nat_ip  = "${google_compute_address.windows1.address}"
    network_tier = "PREMIUM"
  }, ]


}



module "mig" {
  # source  = "../.terraform/modules/vm/modules/mig"
  source  = "terraform-google-modules/vm/google"
  instance_template = module.instance_template.self_link
  region = "us-east1"
  project_id = "sunlit-almanac-392511"
  hostname = "windows"
  autoscaling_enabled = "true"
  autoscaler_name = "test"
  autoscaling_lb = []
  min_replicas = "1"
  max_replicas = "1"
    network_interface {
  }

  health_check = {
    type                = "http"
    initial_delay_sec   = 30
    check_interval_sec  = 30
    healthy_threshold   = 1
    timeout_sec         = 10
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 80
    request             = ""
    request_path        = "/"
    host                = ""
    enable_logging      = false
  }

  named_ports = [{
    name = "http"
    port = "3389"
  },{
    name = "http"
    port = "80"    
  }]
}

module "dynamic_backends" {
  source  = "../.terraform/modules/lb-http/modules/dynamic_backends"
  # insert the 3 required variables here

 project           = "sunlit-almanac-392511"
  name              = "group-http-lb8"
  # target_tags       = [module.mig1.target_tags, module.mig2.target_tags]
  

  backends = {
    dbvm = {
      port                            = 80
      protocol                        = "HTTP"
      port_name                       = "http"
      description                     = null            
      enable_cdn                      = false
      security_policy                 = null
      custom_request_headers          = null
      custom_response_headers         = null
      compression_mode = "DISABLED"

      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 30
        timeout_sec         = 10
        healthy_threshold   = 1
        unhealthy_threshold = 5
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable = false
        sample_rate = null
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = 0.8
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}



