# SCP-JP メンバー管理 API クライアント

`MemberManagementAPIClient` クラスは、SCP-JP メンバー管理APIと連携するためのPythonクライアントです。このクライアントを使用すると、サイト、ユーザー、参加申請、合言葉などの管理が簡単に行えます。

## インストール

このクライアントは `scp_jp_utilities` パッケージの一部として提供されています。

```bash
pip install scp_jp_utilities
```

## 基本的な使い方

### 非同期的な使用方法

```python
from scp_jp.api.member_management import MemberManagementAPIClient

async def main():
    # クライアントの初期化
    client = MemberManagementAPIClient(
        base_url="https://member-management-api.example.com",
        api_key="your_api_key_here"
    )
    
    # サイト一覧の取得
    sites = await client.get_sites()
    print(f"利用可能なサイト数: {len(sites)}")
    
    # 特定のユーザーの取得
    user = await client.get_user(user_id=123)
    print(f"ユーザー名: {user.name}")

# 非同期関数の実行
import asyncio
asyncio.run(main())
```

### 同期的な使用方法

`scp_jp.api.common` モジュールの `run_async` デコレータを使用すると、非同期メソッドを同期的に実行できます。

```python
from scp_jp.api.member_management import MemberManagementAPIClient
from scp_jp.api.common import run_async, make_sync_client

# 方法1: 同期クライアントの作成
client = MemberManagementAPIClient(
    base_url="https://member-management-api.example.com",
    api_key="your_api_key_here"
)
# すべてのメソッドを同期的に使用できるようにラップ
sync_client = make_sync_client(client)

# 同期的にメソッドを呼び出し（awaitなし）
sites = sync_client.get_sites()
print(f"利用可能なサイト数: {len(sites)}")

user = sync_client.get_user(user_id=123)
print(f"ユーザー名: {user.name}")

# 方法2: 個別のメソッドを同期的にラップ
@run_async
async def get_sites_sync(client):
    return await client.get_sites()

client = MemberManagementAPIClient(
    base_url="https://member-management-api.example.com",
    api_key="your_api_key_here"
)

# 同期的に非同期メソッドを実行
sites = get_sites_sync(client)
print(f"利用可能なサイト数: {len(sites)}")
```

## APIクラス

`MemberManagementAPIClient` クラスは以下のエンドポイント群に対応するメソッドを提供しています：

- システム管理
- サイト管理
- ユーザー管理
- 合言葉管理
- 参加申請管理
- 公開エンドポイント

## システム管理 API

### バッチステータスの取得

```python
batch_statuses = await client.get_batch_status()
```

### バッチプロセスの強制開始

```python
result = await client.force_start_batch(task_name="daily_stats")
```

## サイト管理 API

### サイト一覧の取得

```python
sites = await client.get_sites()
```

### サイトの作成

```python
new_site = await client.create_site(site_id=123, name="新しいサイト")
```

### サイトの更新

```python
updated_site = await client.update_site(site_id=123, name="更新されたサイト名")
```

### サイトメンバー統計の取得

```python
stats = await client.get_site_members_stats(
    site_id=123,
    from_date="2023-01-01",
    to_date="2023-12-31"
)
```

### サイトメンバーの権限更新

```python
from scp_jp.api.member_management import PermissionLevel

updated_member = await client.update_site_member_permission(
    site_id=123,
    user_id=456,
    site_permission_level=PermissionLevel.ADMIN
)
```

### サイトメンバーの権限チェック

```python
from scp_jp.api.member_management import PermissionLevel

has_permission = await client.check_site_member_permission(
    site_id=123,
    user_id=456,
    permission_level=PermissionLevel.ADMIN
)
```

### サイトメンバーの外部サイト権限変更

```python
result = await client.change_site_member_privilege(
    site_id=123,
    user_id=456,
    action="to_admin"
)
```

## ユーザー管理 API

### ユーザーの作成

```python
from scp_jp.api.member_management import PermissionLevel

new_user = await client.create_user(
    user_id=456,
    name="新しいユーザー",
    unix_name="new_user",
    avatar_url="https://example.com/avatar.jpg",
    is_deleted=False,
    permission_level=PermissionLevel.VISITOR
)
```

### ユーザー一覧の取得（フィルタリング付き）

```python
from scp_jp.api.member_management import PermissionLevel

users = await client.get_users(
    per_page=50,
    page=1,
    order_by="name",
    order="asc",
    permission_levels=[PermissionLevel.ADMIN, PermissionLevel.MODERATOR],
    is_deleted=False,
    site_ids=[123, 456]
)
```

### ユーザーの取得

```python
user = await client.get_user(user_id=456)
```

### ユーザーの更新

```python
from scp_jp.api.member_management import PermissionLevel

updated_user = await client.update_user(
    user_id=456,
    name="更新されたユーザー名",
    unix_name="updated_unix_name",
    avatar_url="https://example.com/new_avatar.jpg",
    is_deleted=False,
    permission_level=PermissionLevel.MODERATOR
)
```

### ユーザーの権限更新

```python
from scp_jp.api.member_management import PermissionLevel

updated_user = await client.update_user_permission(
    user_id=456,
    permission_level=PermissionLevel.ADMIN
)
```

### ユーザーの権限チェック

```python
from scp_jp.api.member_management import PermissionLevel

has_permission = await client.check_user_permission(
    user_id=456,
    permission_level=PermissionLevel.ADMIN
)
```

## 合言葉管理 API

### 合言葉の作成

```python
new_password = await client.create_application_password(
    site_id=123,
    password="新しい合言葉",
    is_enabled=True
)
```

### 合言葉一覧の取得（フィルタリング付き）

```python
passwords = await client.get_application_passwords(
    per_page=50,
    page=1,
    order_by="created_at",
    order="desc",
    site_id=123,
    password="合言葉",
    is_enabled=True
)
```

### 合言葉の有効/無効の切り替え

```python
updated_password = await client.toggle_application_password(password_id=789)
```

### 合言葉の更新

```python
updated_password = await client.update_application_password(
    password_id=789,
    password="更新された合言葉"
)
```

## 参加申請管理 API

### 参加申請一覧の取得（フィルタリング付き）

```python
from scp_jp.api.member_management import Status, DeclineReasonType

requests = await client.get_application_requests(
    per_page=50,
    page=1,
    order_by="created_at",
    order="desc",
    user_id=456,
    site_id=123,
    statuses=[Status.PENDING],
    decline_reason_types=[DeclineReasonType.INCORRECT_PASSWORD]
)
```

### 拒否理由タイプの取得

```python
reason_types = await client.get_decline_reason_types()
```

### 参加申請の取得

```python
request = await client.get_application_request(request_id=101)
```

### 参加申請の承認

```python
result = await client.approve_application_request(
    request_id=101,
    reviewer_id=456
)
```

### 参加申請の拒否

```python
from scp_jp.api.member_management import DeclineReasonType

result = await client.decline_application_request(
    request_id=101,
    reviewer_id=456,
    decline_reason_type=DeclineReasonType.INCORRECT_PASSWORD,
    decline_reason_detail="合言葉が不正確です"
)
```

## Enum値の定数

### PermissionLevel (権限レベル)

```python
class PermissionLevel(IntEnum):
    VISITOR = 10      # 訪問者（デフォルト）
    CONTRIBUTOR = 20  # 貢献者
    MODERATOR = 30    # モデレーター
    ADMIN = 40        # 管理者
    SYSTEM_ADMIN = 50 # システム管理者
```

### Status (ステータス)

```python
class Status(IntEnum):
    PENDING = 0                # 未処理
    APPROVED = 1               # 承認済み
    DECLINED = 2               # 拒否済み
    CANCELLED_OR_MISSING = 9   # キャンセルまたは手動処理済
```

### DeclineReasonType (拒否理由タイプ)

```python
class DeclineReasonType(IntEnum):
    INCORRECT_PASSWORD = 1                     # 合言葉不備
    REASON_NOT_SPECIFIED_OR_INAPPROPRIATE = 2  # 参加希望理由の未記載／不適切内容の記載
    ROLL_PLAYING = 3                           # ロールプレイ
    INCORRECT_JAPANESE = 4                     # 日本語不備
    CONTAINING_SENSITIVE_INFORMATION = 5       # 個人情報等の記載
    FOR_CONTACT = 6                            # 問い合わせ用途
    OTHER = 9                                  # その他
```

## データモデル

### ユーザー関連

```python
class User(BaseModel):
    id: int
    name: str
    unix_name: str
    avatar_url: HttpUrl
    is_deleted: bool = False
    permission_level: PermissionLevel = PermissionLevel.VISITOR
    created_at: datetime
    updated_at: datetime

class UserWithSiteMemberships(BaseModel):
    id: int
    name: str
    unix_name: str
    avatar_url: HttpUrl
    is_deleted: bool = False
    permission_level: PermissionLevel = PermissionLevel.VISITOR
    site_memberships: List[Any]
    created_at: datetime
    updated_at: datetime
```

### サイト関連

```python
class Site(BaseModel):
    id: int
    name: str
    created_at: datetime
    updated_at: datetime

class SiteWithMembersCount(BaseModel):
    id: int
    name: str
    members_count: int
    created_at: datetime
    updated_at: datetime

class SiteMember(BaseModel):
    id: int
    site_id: int
    user_id: int
    is_resigned: bool = False
    site_permission_level: Optional[PermissionLevel] = None
    effective_permission_level: PermissionLevel
    joined_at: datetime
    created_at: datetime
    updated_at: datetime
```

### 合言葉関連

```python
class ApplicationPassword(BaseModel):
    id: int
    site_id: int
    password: str
    is_enabled: bool = True
    created_at: datetime
    updated_at: datetime
```

### 参加申請関連

```python
class SiteApplicationWithDetails(BaseModel):
    id: int
    status: Status
    acquired_at: datetime
    text: str
    decline_reason_type: Optional[DeclineReasonType] = None
    decline_reason_detail: Optional[str] = None
    reviewed_at: Optional[datetime] = None
    reviewed_by: Optional[Dict[str, Any]] = None
    site: Dict[str, Any]
    user: Dict[str, Any]
    password: Optional[str] = None
    created_at: datetime
    updated_at: datetime
```

## エラーハンドリング

APIクライアントは、エラーが発生した場合に `httpx.HTTPStatusError` 例外を発生させます。これをキャッチして適切に処理することができます。

```python
try:
    site = await client.get_sites()
except httpx.HTTPStatusError as e:
    if e.response.status_code == 404:
        print("サイトが見つかりませんでした")
    else:
        print(f"APIエラー: {e}")
```

## 注意事項

- このクライアントは基本的に非同期APIを使用しています。
  - 非同期コンテキストでは `await` キーワードを使用して実行します。
  - 同期的に使用するには、`run_async` デコレータか `make_sync_client` 関数を利用します。
- API呼び出しにはヘッダーに有効なAPIキーが必要です。
- `httpx` パッケージに依存しているため、インストールされていることを確認してください。