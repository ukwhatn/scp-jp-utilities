# SCP-JP アカウント連携 API クライアント

`LinkerAPIClient` クラスは、SCP-JP アカウント連携APIと連携するためのPythonクライアントです。このクライアントを使用すると、Discord IDとWikidotアカウントの連携管理が簡単に行えます。

## インストール

このクライアントは `scp_jp_utilities` パッケージの一部として提供されています。

```bash
pip install scp_jp_utilities
```

## 基本的な使い方

### 非同期的な使用方法

```python
from scp_jp.api.linker import LinkerAPIClient

async def main():
    # クライアントの初期化
    client = LinkerAPIClient(
        base_url="https://account-linker-api.example.com",
        api_key="your_api_key_here"
    )
    
    # 連携フローを開始
    response = await client.flow_start(
        discord_id="123456789012345678",
        discord_username="user_name",
        discord_avatar="avatar_url"
    )
    print(f"連携フローURL: {response.url}")
    
    # 連携状態の確認
    recheck_result = await client.flow_recheck(
        discord_id="123456789012345678",
        discord_username="user_name",
        discord_avatar="avatar_url"
    )
    print(f"連携済みWikidotアカウント数: {len(recheck_result.wikidot)}")

# 非同期関数の実行
import asyncio
asyncio.run(main())
```

### 同期的な使用方法

`scp_jp.api.common` モジュールの `run_async` デコレータを使用すると、非同期メソッドを同期的に実行できます。

```python
from scp_jp.api.linker import LinkerAPIClient
from scp_jp.api.common import run_async, make_sync_client

# 方法1: 同期クライアントの作成
client = LinkerAPIClient(
    base_url="https://account-linker-api.example.com",
    api_key="your_api_key_here"
)
# すべてのメソッドを同期的に使用できるようにラップ
sync_client = make_sync_client(client)

# 同期的にメソッドを呼び出し（awaitなし）
response = sync_client.flow_start(
    discord_id="123456789012345678",
    discord_username="user_name",
    discord_avatar="avatar_url"
)
print(f"連携フローURL: {response.url}")

# 方法2: 個別のメソッドを同期的にラップ
@run_async
async def start_flow_sync(client, discord_id, discord_username, discord_avatar):
    return await client.flow_start(discord_id, discord_username, discord_avatar)

client = LinkerAPIClient(
    base_url="https://account-linker-api.example.com",
    api_key="your_api_key_here"
)

# 同期的に非同期メソッドを実行
response = start_flow_sync(
    client,
    "123456789012345678",
    "user_name",
    "avatar_url"
)
print(f"連携フローURL: {response.url}")
```

## APIクラス

`LinkerAPIClient` クラスは以下のエンドポイント群に対応するメソッドを提供しています：

- 連携フロー管理
- アカウントリスト取得
- アカウント連携管理
- システム管理

## 連携フロー管理 API

### 連携フローの開始

```python
response = await client.flow_start(
    discord_id="123456789012345678",
    discord_username="user_name",
    discord_avatar="avatar_url"
)
```

### 連携フローの認証

```python
result = await client.flow_auth(token="auth_token")
```

### 連携フローのコールバック処理

```python
result = await client.flow_callback(code="auth_code", state="state_parameter")
```

### 連携状態の再確認

```python
recheck_result = await client.flow_recheck(
    discord_id="123456789012345678",
    discord_username="user_name",
    discord_avatar="avatar_url"
)
```

## アカウントリスト取得 API

### Discord IDに紐づくアカウント情報の取得

```python
account_list = await client.account_list(
    discord_ids=["123456789012345678", "234567890123456789"]
)
```

### すべてのDiscordアカウント情報の取得

```python
discord_accounts = await client.discord_account_list()
```

### すべてのWikidotアカウント情報の取得

```python
wikidot_accounts = await client.wikidot_account_list()
```

## アカウント連携管理 API

### アカウント連携の解除

```python
result = await client.unlink_account(
    discord_id=123456789012345678,
    wikidot_id=12345
)
```

### アカウント連携の復活

```python
result = await client.relink_account(
    discord_id=123456789012345678,
    wikidot_id=12345
)
```

## システム管理 API

### システムのヘルスチェック

```python
health_status = await client.healthcheck()
```

## データモデル

`LinkerAPIClient`クラスは以下のデータモデルを使用しています：

### DiscordAccountSchema

```python
class DiscordAccountSchema(BaseModel):
    id: str
    username: str
    avatar: str
```

### DiscordAccountSchemaForManage

```python
class DiscordAccountSchemaForManage(BaseModel):
    id: str
    username: str
    avatar: str
    created_at: datetime
    updated_at: datetime
    unlinked_at: Optional[datetime] = None
```

### AccountResponseWikidotBaseSchema

```python
class AccountResponseWikidotBaseSchema(BaseModel):
    id: int
    username: str
    unixname: str
    is_jp_member: bool
```

### WikidotAccountSchemaForManage

```python
class WikidotAccountSchemaForManage(BaseModel):
    id: int
    username: str
    unixname: str
    is_jp_member: bool
    created_at: datetime
    updated_at: datetime
    unlinked_at: Optional[datetime] = None
```

### FlowStartResponseSchema

```python
class FlowStartResponseSchema(BaseModel):
    url: str
```

### FlowRecheckResponseSchema

```python
class FlowRecheckResponseSchema(BaseModel):
    discord: DiscordAccountSchema
    wikidot: List[AccountResponseWikidotBaseSchema]
```

### AccountListResponseSchema

```python
class AccountListResponseSchema(BaseModel):
    result: Dict[str, AccountResponseFromDiscordSchema]
```

### ListDiscordResponseSchema

```python
class ListDiscordResponseSchema(BaseModel):
    result: List[ListDiscordItemSchema]
```

### ListWikidotResponseSchema

```python
class ListWikidotResponseSchema(BaseModel):
    result: List[ListWikidotItemSchema]
```

## エラーハンドリング

APIクライアントは、エラーが発生した場合に `httpx.HTTPStatusError` 例外を発生させます。これをキャッチして適切に処理することができます。

```python
try:
    response = await client.flow_start(
        discord_id="123456789012345678",
        discord_username="user_name",
        discord_avatar="avatar_url"
    )
except httpx.HTTPStatusError as e:
    if e.response.status_code == 401:
        print("認証エラー: APIキーが無効です")
    else:
        print(f"APIエラー: {e}")
```

## 注意事項

- このクライアントは基本的に非同期APIを使用しています。
  - 非同期コンテキストでは `await` キーワードを使用して実行します。
  - 同期的に使用するには、`run_async` デコレータか `make_sync_client` 関数を利用します。
- API呼び出しにはヘッダーに有効なAPIキーが必要です。
- `httpx` パッケージに依存しているため、インストールされていることを確認してください。