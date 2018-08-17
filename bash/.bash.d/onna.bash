eval "$(_ONNA_ES_COMPLETE=source onna-es)"

export ONNA_DEPLOY_CLUSTERS_CONF=/home/jordif/code/onna/charts/clusters/
export PATH=$PATH:~/code/onna/ops-team/scripts/deploy_pipeline
eval "$(_DEPLOY_PIPELINE_COMPLETE=source deploy-pipeline)"


alias cdo='cd ~/code/onna'

versionschart () {
    curl -s https://<user>:<password>@harmony.onna.com/api/charts/$1 | jq '.[].version'
}
