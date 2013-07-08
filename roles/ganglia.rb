name "ganglia"
description "deploy ganglia"
run_list "recipe[ganglia]", "recipe[ganglia::gmetad]", "recipe[ganglia::web]", "recipe[ganglia::graphite]"

