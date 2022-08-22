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
`;

// a non-deferred query
const NON_DEFERRED_QUERY = gql`
query deferVariation {
  allProducts {
    ...MyFragment
    sku,
    id
  }
}
fragment MyFragment on Product {
  variation { name }
}
`;

function TestQuery() {
  const { loading, error, data } = useQuery(TEST_QUERY);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error :(</p>;

  return data.allProducts.map(({ id, delivery }) => (
    <div key={id}>
      <p>{id}</p>
      <p>{delivery.estimatedDelivery}</p>
      <p>{delivery.fastestDelivery}</p>
    </div>
  ));
}

function DeferredProducts() {
  return Render(DEFERRED_QUERY)
}

function NonDeferredProducts() {
  return Render(NON_DEFERRED_QUERY)
}

function Render(query) {
  const { loading, error, data } = useQuery(query);

  if (loading) return <p>Loading...</p>;
  if (error) {
	console.log(error);
	return <p>Error :(</p>;
  }

  return (
    <div>

    {data.allProducts.map(({ id, variation }) => {
      if(variation) {
        return <div key={id}>
        <p>{id} : <b>{variation.name}</b></p>
        </div>
      } else {
        return <div key={id}>
        <p>{id}</p>
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
          <p>Testing @defer with Apollo Router.</p>
        </header>
        <div className="Grid-column">
          <div>
            <h2 className="Test-query">A test query 🧪 </h2>
            <TestQuery />
          </div>
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
