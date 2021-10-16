#!/bin/bash

################################################################## 
# Delete service connections in pagopa.it org                    #
# The following service connections need to be recreated         #
# since we are moving the subscription PROD-IO in a new tenant   #
##################################################################

echo "Run delete service connection."


#organization
ORG=https://dev.azure.com/pagopaspa

# delete service endpoint
delete_se() {
    # param 
    # 1. organization
    # 2. project
    # 3. service endpoint name


    id=$(az devops service-endpoint list \
        --org $1  \
        --project $2 \
        -o tsv \
        --query "[?name == '$3'].id" )

    echo "Deleting $2 servie endpoint $3 (${id})"

    # az devops service-endpoint delete \
    # --id ${id} \
    # --org $1 \
    # --project $2    
}


PROJECT=io-pay-projects

for i in "$PROJECT DEV-IO-SERVICE-CONN" "$PROJECT PROD-IO-SERVICE-CONN"
do
    set -- $i # convert the "tuple" into the param args $1 $2...
    delete_se $ORG $1 $2
    echo "...."
done

