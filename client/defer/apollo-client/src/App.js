import logo from "./logo.png";
import "./App.css";
import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  useQuery,
  gql,
} from "@apollo/client";

const client = new ApolloClient({
  uri: "http://localhost:4000/",
  cache: new InMemoryCache(),
});

// a test query

const TEST_QUERY = gql`
  query Query {
    allProducts {
      id
      delivery {
        estimatedDelivery
        fastestDelivery
      }
    }
  }
`;

// a deferred query
const DEFERRED_QUERY = gql`
query deferDeliveryExample {
  allProducts {
    id
    name
    ...MyFragment @defer
  }
}
fragment MyFragment on Product {
  delivery {
    estimatedDelivery
    fastestDelivery
  }
}
`;

// a non-deferred query
const NON_DEFERRED_QUERY = gql`
query deferDeliveryExample {
  allProducts {
    id
    name
    ...MyFragment
  }
}
fragment MyFragment on Product {
  delivery {
    estimatedDelivery
    fastestDelivery
  }
}
`;

function DeferredProducts() {
  console.log("DeferredProducts")
  return Render(DEFERRED_QUERY)
}

function NonDeferredProducts() {
  return Render(NON_DEFERRED_QUERY)
}

function Render(query) {
  const { loading, error, data } = useQuery( query );

  console.log("Render:")
  console.log(loading, error, data)

  if (loading) return <p>Loading...</p>;
  if (error) {
	console.log(error);
	return <p>Error :( {JSON.stringify(error)}</p>;
  }

  if (!data) {
	return <p>Still no data :(</p>;
  }

  return (
    <div>

    {data.allProducts.map(({ id, name, delivery }) => {
      if(delivery) {
        return <div key={id}>
        <p className="Product-title">{id} : <b>{name}</b></p>
        <p className="Delivery-text">Estimated Delivery : <b>{delivery.estimatedDelivery}</b></p>
        <p className="Delivery-text">Fastest Delivery : <b>{delivery.fastestDelivery}</b></p>
        </div>
      } else {
        return <div key={id}>
        <p>{id} : <b>{name}</b></p>
        </div>
      }
    })}
    </div>
  )
}

function App() {
  return (
    <ApolloProvider client={client}>
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <p>Testing @defer with Apollo Client and Apollo Router.</p>
        </header>
        <div className="Grid-column">
          <div>
            <h2 className="Deferred-query">A deferred query 🚀</h2>
            <DeferredProducts />
          </div>
          <div>
            <h2 className="Nondeferred-query">A non-deferred query ⏲️</h2>
            <NonDeferredProducts />
          </div>
        </div>
      </div>
    </ApolloProvider>
  );
}

export default App;
