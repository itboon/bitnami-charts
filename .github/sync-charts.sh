#!/bin/bash

export CHART_BASE_URL='https://helm-charts.itboon.top'

clone_charts_git_repo() {
  local git_tmp_root="$1"
  if [[ -n "$GITHUB_ACTION" ]]; then
    echo "[exec] rm -rf $git_tmp_root"
    rm -rf "$git_tmp_root"
  fi
  mkdir -p "$git_tmp_root"
  if [[ ! -d "$git_tmp_root/.git" ]]; then
    git clone -b main --depth=1 "$GIT_REPO_URL" "$git_tmp_root"
  fi
}

sync_charts() {
  local git_tmp_root="/tmp/tmpchart/$CHART_NAMESPACE"
  clone_charts_git_repo "$git_tmp_root"
  local charts_dir="charts/$CHART_NAMESPACE"
  if [[ "$CHART_NAMESPACE" == "bitnami" ]]; then
    local charts_dir="charts-$CHART_NAMESPACE"
    rm -rf "$charts_dir"
    mkdir -p "$charts_dir"
    cp -R "$git_tmp_root/bitnami/." "$charts_dir/"
  fi
  echo "[debug] ls -alh $charts_dir"; ls -alh "$charts_dir"
}

verify_bitnami_chart_common_dependencies() {
  local chart_root="$1"
  local lock_version="$2"
  local chart_yaml="$chart_root/Chart.yaml"
  local chart_version=$(yq '.version' $chart_yaml)
  if [[ "$chart_version" == "$lock_version" ]]; then
    return
  else
    echo "[warn] common chart 版本不匹配"
    return "400"
  fi
}

main() {
  export GIT_REPO_URL='https://github.com/bitnami/charts.git'
  export CHART_NAMESPACE="bitnami"
  sync_charts
}

# set -x
main
