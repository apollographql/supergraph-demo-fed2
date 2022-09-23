// At the supergraph_service stage, register callbacks for processing requests
fn supergraph_service(service) {
    const request_callback = Fn("process_request"); // This is standard Rhai functionality for creating a function pointer
    service.map_request(request_callback); // Register the callback
}

// Generate a log for each request
fn process_request(request) {
    let start = apollo_start.elapsed;
    // ... Do some processing
    let duration = apollo_start.elapsed - start;
    log_info(`custom processing took: ${duration}`);
}        