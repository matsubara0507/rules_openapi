{-
   Swagger Petstore
   No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)

   The version of the OpenAPI document: 1.0.0

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git

   DO NOT EDIT THIS FILE MANUALLY.

   For more info on generating Elm code, see https://eriktim.github.io/openapi-elm/
-}


module Api.Request.Pets exposing
    ( createPets
    , listPets
    , showPetById
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode



createPets : Api.Request ()
createPets =
    Api.request
        "POST"
        "/pets"
        []
        []
        []
        Nothing
        (Json.Decode.succeed ())



listPets : Maybe Int -> Api.Request (List Api.Data.Pet)
listPets limit_query =
    Api.request
        "GET"
        "/pets"
        []
        [ ( "limit", Maybe.map String.fromInt limit_query ) ]
        []
        Nothing
        (Json.Decode.list Api.Data.petDecoder)



showPetById : String -> Api.Request Api.Data.Pet
showPetById petId_path =
    Api.request
        "GET"
        "/pets/{petId}"
        [ ( "petId", identity petId_path ) ]
        []
        []
        Nothing
        Api.Data.petDecoder
