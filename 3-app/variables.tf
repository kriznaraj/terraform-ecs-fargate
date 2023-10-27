variable "region" {
  default = "us-east-1"
}

variable "remote_state_key" {}
variable "remote_state_bucket" {}

#app variable
variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory" {}
variable "docker_container_port" {}
# variable "varvalue" {}
variable "desired_task_number" {}
