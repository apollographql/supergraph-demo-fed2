fn router_service(service) {
    // Define a closure to process our response
    let f = |response| {
        let start = apollo_start.elapsed;
        // ... Do some processing
        let duration = apollo_start.elapsed - start;
        print(`response processing took: ${duration}`);

        // Log out any errors we may have
        print(response.body.errors);
    };
    // Map our response using our closure
    service.map_response(f);
}