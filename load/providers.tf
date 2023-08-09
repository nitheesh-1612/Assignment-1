provider "google" {
    credentials = file("key.json")
    project = "sunlit-almanac-392511"
    region  = "us-west1"
}

provider "google-beta" {
    credentials = file("key.json")
    project = "sunlit-almanac-392511"
    region  = "us-west1"
}

