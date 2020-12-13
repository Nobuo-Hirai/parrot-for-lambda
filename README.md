# parrot-for-Lambda

## Description
AWS Lambdaで動作するSlack連携アプリです。  
SlackでAppにメンションをつけてメッセージを送信すると同じメッセージを返してくるオウム返しのアプリです。  

## development environment setup
#### rubyのinstall
ruby 2.5.8をインストールして下さい。

#### git clone & bundle install
```
git clone git@github.com:Nobuo-Hirai/parrot-for-Lambda.git
```

```
# gemもLambdaのアプリケーション内に含める必要があるので vendor/bundle 配下へinsallしてください。
bundle config set --local path 'vendor/bundle'
bundle install
```

#### Lambdaの環境変数
Lambdaの環境変数へセットする内容は以下の通りです。 

| key | value |
| ---- | ---- |
| api_app_id | Slackのapi_app_id (SlackのAppページに表示されているApp ID) |
| channel_id | 呼び出し元のSlack channel id。対象のchannel以外は実行を許可しない(channel idの確認方法は該当のchannelをアプリで選択して、右クリックでリンクをコピーします。それをブラウザへ貼り付け、/archives/以降がidです。) |
| slack_token | Slackのaccess token(Bot User OAuth Access Token) |

## Lambdaへdeploy
Lambdaへのdeployはソースをzipにしてアップロードします。

### zip file作成
```
zip -r parrot-for-lambda.zip vendor lambda_function.rb
```

