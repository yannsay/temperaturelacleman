structure(list(method = "GET", url = "https://alplakes-api.eawag.ch/simulations/depthtime/delft3d-flow/geneva/202406090100/20242200/46.303696/6.239853", 
    status_code = 422L, headers = structure(list(Server = "nginx", 
        Date = "Fri, 23 Aug 2024 14:03:48 GMT", `Content-Type` = "application/json", 
        `Content-Length` = "151", Connection = "keep-alive"), class = "httr2_headers"), 
    body = charToRaw("{\"detail\":[{\"loc\":[\"path\",\"end_time\"],\"msg\":\"string does not match regex \\\"^\\\\d{12}$\\\"\",\"type\":\"value_error.str.regex\",\"ctx\":{\"pattern\":\"^\\\\d{12}$\"}}]}"), 
    cache = new.env(parent = emptyenv())), class = "httr2_response")
