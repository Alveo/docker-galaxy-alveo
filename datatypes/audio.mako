
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>${dataset.name}</title>
</head>
<body>
    <h1>${dataset.name}</h1>

    <div>
    <audio controls='controls'>
        Your browser does not support the <code>audio</code> element.
        <source src="${h.url_for( controller='/dataset', action='display', dataset_id=trans.security.encode_id( dataset.id ), to_ext=dataset.ext )}
" type="audio/wav" />
    </audio>
    </div>

</body>
