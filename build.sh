#!/bin/bash

#Do grunt work
# nvm install 12.20
# nvm use 12.20

if [[ $BUILD == "true" ]]; then
if [[ ! -d ./node_modules ]]; then
  echo "dependencies not installed try running: yarn"
  exit 1
fi
rm -rf ./oci-logs-datasource
rm ./oci-logs-datasource.zip 
rm ./plugin.tar
# yarn create @grafana/plugin
yarn run build
if [ $? -ne 0 ]; then
    echo "yarn returned error"
    exit 1
fi

mage --debug -v

cp LICENSE.txt ./dist/LICENSE

if [ -z $1 ]; then
  echo "sign argument not specified, continuing without sign the plugin"
else
  if [ $1 = "sign" ]; then
    npx @grafana/sign-plugin
  else
    echo "Usage: ./build.sh <sign>"
  fi  
fi

mv ./dist ./oci-logs-datasource
tar cvf plugin.tar ./oci-logs-datasource
zip -r oci-logs-datasource ./oci-logs-datasource

# Instructions for signing
# Please make sure
# nvm install 12.20

# nvm use 12.20

# yarn
# For grafana publishing
# yarn install --pure-lockfile && yarn build
#
# Please make sure if you have the api keys installed in bash profile in name,  GRAFANA_API_KEY
# Note : Please make sure that you are running the commands in a non-proxy env and without vpn, else grafana signing might fail"
# yarn  global add @grafana/toolkit
# grafana-toolkit plugin:sign

fi

if [[ $DEPLOY == "true" ]]; then
docker stack rm grafana
sleep 5
cp -rp oci-logs-datasource ../../../../../plugin/grafanavar/plugins/
docker stack deploy grafana -c ../../../../../plugin/docker-compose.yaml
fi
