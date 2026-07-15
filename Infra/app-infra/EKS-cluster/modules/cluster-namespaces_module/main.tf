resource "kubernetes_namespace" "cluster_namespaces" {
    for_each = toset(["dev" , "test" , "prod"]) # make loop on each item in list
    metadata {
      name = each.key

    # labels = {
    #   env = each.key
    #   managed-by = "terraform"
    #   environment = each.key
    # }
        }

    # depends_on = [ module.eks ]
  
}