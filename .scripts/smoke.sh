#!/bin/bash

PORT="${1:-4000}"
COUNT="${2:-1}"
TESTS=(1 2 3 4 5 6 7)

# --------------------------------------------------------------------
# TEST 1
# --------------------------------------------------------------------
DESCR_1="allProducts with delivery"
OPNAME_1="allProdDelivery"
read -r -d '' QUERY_1 <<"EOF"
query allProdDelivery {
  allProducts {
    delivery {
      estimatedDelivery,
      fastestDelivery
    },
    createdBy {
      name,
      email
    }
  }
}
EOF

OP_1=equals

read -r -d '' EXP_1 <<"EOF"
{"data":{"allProducts":[{"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"},"createdBy":{"name":"Apollo Studio Support","email":"support@apollographql.com"}},{"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"},"createdBy":{"name":"Apollo Studio Support","email":"support@apollographql.com"}}]}}
EOF

# --------------------------------------------------------------------
# TEST 2
# --------------------------------------------------------------------
DESCR_2="allProducts with totalProductsCreated"
OPNAME_2="allProdCreated"
read -r -d '' QUERY_2 <<"EOF"
query allProdCreated {
  allProducts {
    id,
    sku,
    createdBy {
      email,
      totalProductsCreated
    }
  }
}
EOF

OP_2=equals

read -r -d '' EXP_2 <<"EOF"
{"data":{"allProducts":[{"id":"apollo-federation","sku":"federation","createdBy":{"email":"support@apollographql.com","totalProductsCreated":1337}},{"id":"apollo-studio","sku":"studio","createdBy":{"email":"support@apollographql.com","totalProductsCreated":1337}}]}}
EOF

# --------------------------------------------------------------------
# TEST 3 - @inaccessible in subgraphs
# --------------------------------------------------------------------
DESCR_3="hidden: String @inaccessible should return error"
OPNAME_3="inaccessibleError"
read -r -d '' QUERY_3 <<"EOF"
query inaccessibleError {
  allProducts {
    id,
    hidden,
    dimensions {
      size,
      weight
    }
  }
}
EOF

OP_3=contains

read -r -d '' EXP_3 <<"EOF"
Cannot query field \"hidden\" on type \"ProductItf\".
EOF

# --------------------------------------------------------------------
# TEST 4
# --------------------------------------------------------------------
DESCR_4="exampleQuery with pandas"
OPNAME_4="exampleQuery"
read -r -d '' QUERY_4 <<"EOF"
query exampleQuery {
 allProducts {
   id,
   sku,
   dimensions {
     size,
     weight
   }
   delivery {
     estimatedDelivery,
     fastestDelivery
   }
 }
 allPandas {
   name,
   favoriteFood
 }
}
EOF

OP_4=equals

read -r -d '' EXP_4 <<"EOF"
{"data":{"allProducts":[{"id":"apollo-federation","sku":"federation","dimensions":{"size":"1","weight":1},"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"}},{"id":"apollo-studio","sku":"studio","dimensions":{"size":"1","weight":1},"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"}}],"allPandas":[{"name":"Basi","favoriteFood":"bamboo leaves"},{"name":"Yun","favoriteFood":"apple"}]}}
EOF

# --------------------------------------------------------------------
# TEST 5
# --------------------------------------------------------------------
DESCR_5="exampleQuery with reviews and override"
OPNAME_5="allProductsWithReviews"
read -r -d '' QUERY_5 <<"EOF"
query allProductsWithReviews {
 allProducts {
   id,
   sku,
   dimensions {
     size,
     weight
   }
   delivery {
     estimatedDelivery,
     fastestDelivery
   }
   reviewsScore,
   reviews {
     body
   }
 }
}
EOF

OP_5=equals

read -r -d '' EXP_5 <<"EOF"
{"data":{"allProducts":[{"id":"apollo-federation","sku":"federation","dimensions":{"size":"1","weight":1},"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"},"reviewsScore":4.6,"reviews":[{"body":"A review for Apollo Federation"}]},{"id":"apollo-studio","sku":"studio","dimensions":{"size":"1","weight":1},"delivery":{"estimatedDelivery":"6/25/2021","fastestDelivery":"6/24/2021"},"reviewsScore":4.6,"reviews":[{"body":"A review for Apollo Studio"}]}]}}
EOF

# --------------------------------------------------------------------
# TEST 6
# --------------------------------------------------------------------
DESCR_6="defer variation query"
OPNAME_6="deferVariation"
ISSLOW_6="true"
read -r -d '' QUERY_6 <<"EOF"
query deferVariation {
  allProducts {
    ...MyFragment @defer
    sku,
    id
  }
}
fragment MyFragment on Product {
  variation { name }
}
EOF
OP_6=equals

read -r -d '' EXP_6 <<"EOF"
--graphql
content-type: application/json

{"data":{"allProducts":[{"sku":"federation","id":"apollo-federation"},{"sku":"studio","id":"apollo-studio"}]},"hasNext":true}
--graphql
content-type: application/json

{"data":{"allProducts":[{"variation":{"name":"platform"}},{"variation":{"name":"platform-name"}}]},"hasNext":true}
--graphql--
content-type: application/json

{"hasNext":false}
EOF

# --------------------------------------------------------------------
# TEST 7
# --------------------------------------------------------------------
DESCR_7="deferred user query"
OPNAME_7="deferUser"
read -r -d '' QUERY_7 <<"EOF"
query deferUser { 
  allProducts { 
    createdBy { 
      ...MyFragment @defer
    }
    sku
    id 
  }     
}
     
fragment MyFragment on User { name }
EOF

OP_7=equals

read -r -d '' EXP_7 <<"EOF"
--graphql
content-type: application/json

{"data":{"allProducts":[{"sku":"federation","id":"apollo-federation"},{"sku":"studio","id":"apollo-studio"}]},"hasNext":true}
--graphql
content-type: application/json

{"data":{"allProducts":[{"createdBy":{"name":"Apollo Studio Support"}},{"createdBy":{"name":"Apollo Studio Support"}}]},"hasNext":true}
--graphql--
content-type: application/json

{"hasNext":false}
EOF

set -e

OK_CHECK="\xE2\x9C\x85"
FAIL_MARK="\xE2\x9D\x8C"
ROCKET="\xF0\x9F\x9A\x80"

printf "Running smoke tests ... $ROCKET $ROCKET $ROCKET\n"
sleep 2

run_tests ( ){
  for (( i=1; i<=$COUNT; i++ )); do
    for test in ${TESTS[@]}; do
      descr_var="DESCR_$test"
      query_var="QUERY_$test"
      exp_var="EXP_$test"
      op_var="OP_$test"
      opname_var="OPNAME_$test"
      is_slow_var="ISSLOW_$test"

      DESCR="${!descr_var}"
      QUERY=$(echo "${!query_var}" | tr '\n' ' ' | awk '$1=$1')
      EXP="${!exp_var}"
      OP="${!op_var}"
      OPNAME="${!opname_var}"
      ISSLOW="${!is_slow_var}"
      CMD=(curl -X POST -H "Content-Type: application/json" -H "apollographql-client-name: smoke-test" --data "{ \"query\": \"${QUERY}\", \"operationName\": \"$OPNAME\" }" http://localhost:$PORT/ )

      if [ $i -gt 1 ]; then
        if [ "$ISSLOW" == "true" ]; then
          continue
        fi
      fi

      if [ $COUNT -le 1 ]; then
        echo ""
        echo "=============================================================="
        echo "TEST $test: $DESCR"
        echo "=============================================================="
        echo "${CMD[@]}"
      fi

      # execute operation
      set +e
      ACT=$("${CMD[@]}" | tr -d '\r' 2>/dev/null)
      EXIT_CODE=$?
      if [ $EXIT_CODE -ne 0 ]; then
        if [ $EXIT_CODE -eq 7 ]; then
          printf "CURL ERROR 7: Failed to connect() to host or proxy.\n"
        elif [ $EXIT_CODE -eq 52 ]; then
          printf "CURL ERROR 52: Empty reply from server.\n"
        elif [ $EXIT_CODE -eq 56 ]; then
          printf "CURL ERROR 56: Recv failure: Connection reset by peer.\n"
        else
          printf "CURL ERROR $EXIT_CODE\n"
        fi
        printf "${ACT}"
        printf '\n'
        exit 1
      fi
      set -e

      OK=0
      if [ "$OP" == "equals" ]; then
        [ "$ACT" == "$EXP" ] && OK=1

      elif [ "$OP" == "startsWith" ]; then
        EXP=$( echo "$EXP" | sed 's|\\|\\\\|g' | sed 's|\[|\\[|g' | sed 's|\]|\\]|g')
        if echo "$ACT" | grep -q "^${EXP}"; then
          OK=1
        fi
      elif [ "$OP" == "contains" ]; then
        EXP=$( echo "$EXP" | sed 's|\\|\\\\|g' | sed 's|\[|\\[|g' | sed 's|\]|\\]|g')
        if echo "$ACT" | grep -q "${EXP}"; then
          OK=1
        fi
      fi

      if [ $OK -eq 1 ]; then
        if [ $COUNT -le 1 ]; then
          echo -------------------------
          echo "[Expected: $OP]"
          echo "$EXP"
          echo -------------------------
          echo "[Actual]"
          echo "$ACT"
          echo -------------------------
          printf "$OK_CHECK Success!\n"
        fi
      else
          echo -------------------------
          printf "$FAIL_MARK TEST $test Failed! \n"
          echo -------------------------
          if [ $COUNT -gt 1 ]; then
            # only show headers for load tests when an error occurs
            echo "=============================================================="
            echo "TEST $test: $DESCR"
            echo "=============================================================="
            echo -------------------------
            printf '%q ' "${CMD[@]}"
            echo -------------------------
          fi
          echo "[Expected: $OP]"
          echo "$EXP"
          echo -------------------------
          echo "[Actual]"
          echo "$ACT"
          echo -------------------------
          printf "$FAIL_MARK TEST $test Failed! \n"
          echo -------------------------
          exit 1
      fi
    done
    if [ $COUNT -gt 1 ]; then
      printf "$OK_CHECK $i \n"
    fi
  done

  echo ""
  echo "================================"
  printf "$OK_CHECK ALL TESTS PASS! \n"
  echo "================================"
  echo ""
}

if [ $COUNT -gt 1 ]; then
  time run_tests
else
  run_tests
fi
