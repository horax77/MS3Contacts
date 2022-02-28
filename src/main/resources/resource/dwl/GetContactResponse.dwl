%dw 2.0
output application/json
---
payload groupBy (
	$.Id 
	) pluck ((value,key,index) -> {
	"Identification" : {
        "Id": value[0].Id,
        "FirstName": value[0].FirstName,
        "LastName": value[0].LastName,
        "DOB": value[0].DOB,
        "Gender": value[0].Gender,
        "Title": value[0].Title
    },
    "Addess": value distinctBy ($.AddressId) map {
    	"Id": $.AddressId,
    	"TypeId": $.AddressTypeId,
        "TypeDesc": $.AddressTypeDesc,
		"Number": $.Street,
		"Street": $.StreetNumber,
		"Unit": $.Unit,
		"City": $.City,
        "StateId": $.StateId,
        "StateDesc": $.StateDesc,
		"Zipcode": $.ZipCode
    },
    "Communications": value distinctBy ($.CommunicationChannelId) map {
    	"Id": $.CommunicationChannelId,
		"TypeId": $.CommunicationTypeId,
        "TypeDesc": $.CommunicationTypeDesc,
		"Value": $.value,
		"Preferred" : $.preferredFlg
    }
    }
    ) 