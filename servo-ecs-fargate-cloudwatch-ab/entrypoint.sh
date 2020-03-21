echo $OPSANI_CO_TOKEN > /etc/auth_token
echo $OPTUNE_CO_CONFIG | base64 -d > /servo/config.yaml
python /servo/servo --auth-token=/etc/auth_token $APP_ID