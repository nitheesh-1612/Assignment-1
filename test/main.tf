module "vm_instance_template" {
  source  = "./.terraform/modules/vm/modules/instance_template"
  machine_type = var.machine_type
  network = var.network_name
  project_id = var.project_id
  region = var.region
  source_image = var.image
  source_image_family = var.image_family
  source_image_project = var.image_project
  subnetwork = var.public_subnet
  service_account = var.service_account
  access_config = [{
    nat_ip  = "${google_compute_address.gcp-test-ip3.address}"
    network_tier = var.network_tier
  }, {
    nat_ip  = "${google_compute_address.gcp-test-ip4.address}"
    network_tier = var.network_tier
  }]
}

module "vm_mig" {
  source  = "./.terraform/modules/vm/modules/mig"
  instance_template = module.vm_instance_template3.self_link
  region = var.region
  project_id = var.project_id
  hostname = "windows"
  autoscaling_enabled = "true"
  autoscaler_name = "test"
  min_replicas = "2"
  max_replicas = "10"

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

module "vpc" {
   source  = "../.terraform/modules/network/modules/vpc"
  version = "6.0.1"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "REGIONAL"

  delete_default_internet_gateway_routes = "true"

  subnets = [
     {
      subnet_name           = var.private_subnet
      subnet_ip             = "10.0.2.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    },
    {
      subnet_name           = var.public_subnet
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = var.region
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    }
  ]
}

module "lb-http" {
  source  = "./.terraform/template/dynamic_backends"
  version = "6.3.0"
  # insert the 3 required variables here

 project           = var.project_id
  name              = "group-http-lb1"
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
          group                        = module.vm_mig5.instance_group
          balancing_mode               = null
          capacity_scaler              = null
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

resource "google_compute_address" "gcp-test-ip4" {
  name = "gcp-test-ip4"
  region = "us-east1"
}

resource "google_compute_address" "gcp-test-ip3" {
  name = "gcp-test-ip3"
  region = "us-east1"
}