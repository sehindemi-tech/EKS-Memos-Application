# resource "aws_eks_addon" "pod_identity_agent" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "vpc-cni"
# }