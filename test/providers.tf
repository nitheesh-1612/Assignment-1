provider "google" {
    credentials = file("key.json")
    project = "sunlit-almanac-392511"
    region  = "us-east1"
}

provider "google-beta" {
    credentials = file("key.json")
    project = "sunlit-almanac-392511"
    region  = "us-east1"
}

