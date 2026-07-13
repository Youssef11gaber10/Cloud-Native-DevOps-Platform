# in main.tf collect module i used and give its values and start use them in my code(resources)
module "network" {
    source = "../modules/network_module" # now ask you for variables values to use this module

subnet_variables_list = var.subnet_variables_list # this take its value from .tfvars
region = var.region # this take its value from .tfvars
vpc_cidr = var.vpc_cidr # this take its value from .tfvars  
}

module "ci-resources" {
    source="../modules/ci_resources_module"
    list_public_subnets_ids_ALB = [
        module.network.NM_subnets["public_subnet_1"].id,
        module.network.NM_subnets["public_subnet_2"].id
    ]
    vpc_id=module.network.NM_vpc_id
    public_1_subnet_id = module.network.NM_subnets["public_subnet_1"].id
    private_1_subnet_id = module.network.NM_subnets["private_subnet_1"].id
    private_2_subnet_id = module.network.NM_subnets["private_subnet_2"].id
}