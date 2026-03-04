<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${message_maintenance}</title>
    <style>
        html, body {
            height: 100%;
            margin: 0;
        }
        body {
            background: url('${background_image_url}') no-repeat center center fixed;
            background-size: cover;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .message {
            text-align: center;
            font-size: 4rem;
            padding: 1rem 2rem;
            background: rgba(0,0,0,0.9);
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="message">
        ${message_maintenance}
    </div>
</body>
</html>