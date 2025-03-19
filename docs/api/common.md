# 共通APIユーティリティ

`scp_jp.api.common` モジュールは、APIクライアントの実装に役立つユーティリティ関数を提供しています。特に、非同期APIを同期的に使用するためのヘルパー関数が含まれています。

## 非同期関数の同期実行

### run_async デコレータ

`run_async` デコレータを使用すると、非同期関数を同期的に呼び出せるようにラップすることができます。

```python
from scp_jp.api.common import run_async
import asyncio

@run_async
async def fetch_data():
    await asyncio.sleep(1)
    return "データ"

# 同期的に呼び出し（awaitなし）
result = fetch_data()
print(result)  # "データ"
```

#### 技術的詳細

- イベントループが既に実行中かどうかを検出し、適切に処理します
- イベントループが実行中でない場合は、`asyncio.run()`で一時的なイベントループを作成して実行します
- イベントループが既に実行中の場合は、新しいイベントループを作成して実行します

### make_sync_client 関数

`make_sync_client` 関数は、非同期APIクライアントのすべてのメソッドを同期的に呼び出せるようにラップします。

```python
from scp_jp.api.common import make_sync_client
from scp_jp.api.member_management import MemberManagementAPIClient

# 非同期クライアントのインスタンス化
async_client = MemberManagementAPIClient(
    base_url="https://api.example.com",
    api_key="your_api_key"
)

# すべてのメソッドを同期的に使用できるようにラップ
sync_client = make_sync_client(async_client)

# 同期的にメソッドを呼び出し
sites = sync_client.get_sites()
user = sync_client.get_user(user_id=123)
```

#### 技術的詳細

- `inspect.getmembers()` と `inspect.iscoroutinefunction()` を使用して、非同期メソッドを検出します
- 各非同期メソッドに `run_async` デコレータを適用します
- プライベートメソッド（アンダースコアで始まる名前のメソッド）はラップしません

## 使用上の注意

- 同期的なラッパーは、主に非同期をサポートしていない環境で使用することを目的としています
- 最高のパフォーマンスを得るためには、可能な限り非同期APIを直接使用することをお勧めします
- 既に非同期コンテキスト内にいる場合は、同期的なラッパーを使用せず、直接 `await` で非同期メソッドを呼び出してください