#!/bin/bash

if [[ "${CI}" != "true" ]]; then

  # optional overrides
  graph="$OVERRIDE_APOLLO_GRAPH_REF"
  key="$OVERRIDE_APOLLO_KEY"

  # load defaults if present
  if ls graph-api.env > /dev/null 2>&1; then
    eval "$(cat graph-api.env)"
  fi

  # --------------------------------------------------------------------------
  # APOLLO_KEY
  # --------------------------------------------------------------------------
  if [[ "$key" == "default" ]]; then
    if [[ -n $APOLLO_KEY ]]; then
      key=$APOLLO_KEY
      echo "---------------------------------------"
      echo "Using default APOLLO_KEY"
      echo "---------------------------------------"
    else
      unset key
    fi
  fi

  if [[ -z "${key}" ]]; then
    echo "---------------------------------------"
    echo "Enter your APOLLO_KEY"
    echo "---------------------------------------"
    echo "Go to your graph settings in https://studio.apollographql.com/"
    echo "then create a Graph API Key with Contributor permissions"
    echo "(for metrics reporting) and enter it at the prompt below."

    if [[ -n "$APOLLO_KEY" ]]; then
      echo ""
      echo "press <enter> to use existing key: *************** (from ./graph-api.env)"
    fi

    read -s -p "> " key
    echo
    if [[ -z "$key" ]]; then
      if [[ -n "$APOLLO_KEY" ]]; then
        key=$APOLLO_KEY
      else
        >&2 echo "---------------------------------------"
        >&2 echo "APOLLO_KEY not found"
        >&2 echo "---------------------------------------"
        exit 1
      fi
    fi
  fi

  export APOLLO_KEY=$key

  # --------------------------------------------------------------------------
  # APOLLO_GRAPH_REF
  # --------------------------------------------------------------------------
  echo ""
  if [[ "$graph" == "default" ]]; then
    if [[ -n $APOLLO_GRAPH_REF ]]; then
      graph=$APOLLO_GRAPH_REF
      echo "---------------------------------------"
      echo "Using APOLLO_GRAPH_REF: ${graph}"
      echo "---------------------------------------"
    else
      unset graph
    fi
  fi

  if [[ -z "${graph}" ]]; then
    echo "---------------------------------------"
    echo "Enter your APOLLO_GRAPH_REF"
    echo "---------------------------------------"
    echo "Go to your graph settings in https://studio.apollographql.com/"
    echo "then copy your Graph NAME and optionally @<VARIANT> and enter it at the prompt below."
    echo "@<VARIANT> will default to @current, if omitted."
    echo ""
    echo "Enter the <NAME>@<VARIANT> of a federated graph in Apollo Studio:"
    if [[ -n "$APOLLO_GRAPH_REF" ]]; then
      echo ""
      echo "press <enter> for default: $APOLLO_GRAPH_REF"
    fi
    read -p "> " graph
    if [[ -z "$graph" ]]; then
      if [[ -n "$APOLLO_GRAPH_REF" ]]; then
        graph=$APOLLO_GRAPH_REF
      else
        >&2 echo "---------------------------------------"
        >&2 echo "APOLLO_GRAPH_REF not found"
        >&2 echo "---------------------------------------"
        exit 1
      fi
    fi
  fi

  export APOLLO_GRAPH_REF=$graph
fi

# for docker-compose.managed.yaml env_file and to save defaults for next time
echo "APOLLO_KEY=${APOLLO_KEY}" > graph-api.env
echo "APOLLO_GRAPH_REF=${APOLLO_GRAPH_REF}" >> graph-api.env

ok=1
if [[ -z "${APOLLO_KEY}" ]]; then
  >&2 echo "---------------------------------------"
  >&2 echo "APOLLO_KEY not found"
  >&2 echo "---------------------------------------"
  ok=0
fi

if [[ -z "${APOLLO_GRAPH_REF}" ]]; then
  >&2 echo "---------------------------------------"
  >&2 echo "APOLLO_GRAPH_REF not found"
  >&2 echo "---------------------------------------"
  ok=0
fi

if [[ $ok -eq 0 ]]; then
  exit 1
fi
