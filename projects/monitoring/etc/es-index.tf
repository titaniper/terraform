terraform {
  required_version = ">= 1.0.0"
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~>0.9"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = "hk85tdH35c4BmQYq0s934L0E"
    endpoints = ["http://elasticsearch-es-data.monitoring.svc.cluster.local:9200"]
  }
  kibana {
    username  = "elastic"
    password  = "hk85tdH35c4BmQYq0s934L0E"
    endpoints = ["http://localhost:30601"]
  }
}

resource "elasticstack_elasticsearch_index" "test" {
  name = "test"

  analysis_filter = jsonencode({
    english_stop = {
      type      = "stop",
      stopwords = "_english_"
    }
    english_stemmer = {
      type     = "stemmer"
      language = "english"
    }
    english_possessive_stemmer = {
      type     = "stemmer"
      language = "possessive_english"
    }
  })

  analysis_analyzer = jsonencode({
    default = {
      tokenizer = "standard"
      filter = [
        "english_possessive_stemmer",
        "lowercase",
        "english_stop",
        "english_stemmer",
      ]
    }
  })

  number_of_shards   = 1
  number_of_replicas = 1

  lifecycle {
    ignore_changes = [mappings]
  }
}