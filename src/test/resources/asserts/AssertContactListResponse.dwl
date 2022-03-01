%dw 2.0
import * from dw::test::Asserts
---
payload must equalTo(	
[
  {
    "Identification": {
      "Id": 1,
      "FirstName": "Horacio",
      "LastName": "Espasandin",
      "DOB": "1977-01-08T00:00:00",
      "Gender": "M",
      "Title": "Mule Developer"
    },
    "Addess": [
      {
        "Id": 1,
        "TypeId": 1,
        "TypeDesc": "Home",
        "Number": "Av. Rivadavia",
        "Street": "8861",
        "Unit": "",
        "City": "Ciudad de Buenos Aires",
        "StateId": 1,
        "StateDesc": "Alabama",
        "Zipcode": "1407"
      }
    ],
    "Communications": [
      {
        "Id": 1,
        "TypeId": 1,
        "TypeDesc": "Email",
        "Value": "horax77@gmail.com",
        "Preferred": true
      }
    ]
  }
])