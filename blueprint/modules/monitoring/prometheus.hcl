helm "prometheus_stack" {
  cluster = "k8s_cluster.${var.monitoring_k8s_cluster}"
  
  chart_name = "prometheus-stack"

  chart = "github.com/prometheus-community/helm-charts/charts//kube-prometheus-stack"

  values_string = {
    "alertmanager.enabled" = "false"
    "grafana.enabled" = "false"
  }
  
  health_check {
    timeout = "90s"
    pods = ["release=prometheus-stack"]
  }
}

k8s_config "prometheus_" {
  depends_on = ["helm.prometheus_stack"]

  cluster = "k8s_cluster.${var.monitoring_k8s_cluster}"
  paths = [
    "./k8sconfig/prometheus_operator.yaml",
  ]

  wait_until_ready = true
}

ingress "prometheus" {
  target = "k8s_cluster.${var.monitoring_k8s_cluster}"
  service = "svc/grafana"

  port {
    local = 9090
    remote = 9090
    host = 9090
  }
  
  network {
    name = "network.${var.monitoring_network}"
  }
}
