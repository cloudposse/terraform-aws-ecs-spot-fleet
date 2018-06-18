# output "spot_request_state" {
#   value = "${aws_spot_fleet_request.default.spot_request_state}"
# }

# output "request_id" {
#   value = "${aws_spot_fleet_request.default.id}"
# }

output "cluster_name" {
  value = "${local.cluster_name}"
}

output "cluster_arn" {
  value = "${join("", aws_ecs_cluster.default.*.arn)}"
}
