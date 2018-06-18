output "spot_request_state" {
  value = "${aws_spot_fleet_request.default.spot_request_state}"
}

output "request_id" {
  value = "${aws_spot_fleet_request.default.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.default.name}"
}

output "cluster_arn" {
  value = "${aws_ecs_cluster.default.arn}"
}
