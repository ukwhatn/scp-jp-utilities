# SCP-JP メンバー管理 API クライアント

`MemberManagementAPIClient` クラスは、SCP-JP メンバー管理APIと連携するためのPythonクライアントです。このクライアントを使用すると、サイト、ユーザー、参加申請、合言葉などの管理が簡単に行えます。

## インストール

このクライアントは `scp_jp_utilities` パッケージの一部として提供されています。

```bash
pip install scp_jp_utilities
```

## 基本的な使い方

```python
from scp_jp.api.member_management import MemberManagementAPIClient

# 非同期的な使用方法
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
from scp_jp.api.member_management import SiteCreate

site_data = SiteCreate(id=123, name="新しいサイト")
new_site = await client.create_site(site_data)
```

### サイトの更新

```python
from scp_jp.api.member_management import SiteUpdate

site_data = SiteUpdate(name="更新されたサイト名")
updated_site = await client.update_site(site_id=123, site_data=site_data)
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
from scp_jp.api.member_management import SiteMemberPermissionUpdate, PermissionLevel

permission_data = SiteMemberPermissionUpdate(
    site_permission_level=PermissionLevel.ADMIN
)
updated_member = await client.update_site_member_permission(
    site_id=123,
    user_id=456,
    permission_data=permission_data
)
```

### サイトメンバーの権限チェック

```python
has_permission = await client.check_site_member_permission(
    site_id=123,
    user_id=456,
    permission_level=PermissionLevel.ADMIN
)
```

### サイトメンバーの外部サイト権限変更

```python
from scp_jp.api.member_management import SiteMemberPrivilegeAction

action_data = SiteMemberPrivilegeAction(action="to_admin")
result = await client.change_site_member_privilege(
    site_id=123,
    user_id=456,
    action_data=action_data
)
```

## ユーザー管理 API

### ユーザーの作成

```python
from scp_jp.api.member_management import UserCreate
from pydantic import HttpUrl

user_data = UserCreate(
    id=456,
    name="新しいユーザー",
    unix_name="new_user",
    avatar_url=HttpUrl("https://example.com/avatar.jpg")
)
new_user = await client.create_user(user_data)
```

### ユーザー一覧の取得（フィルタリング付き）

```python
users = await client.get_users(
    per_page=50,
    page=1,
    order_by="name",
    order="asc",
    permission_levels=[PermissionLevel.ADMIN, PermissionLevel.MODERATOR]
)
```

### ユーザーの取得

```python
user = await client.get_user(user_id=456)
```

### ユーザーの更新

```python
from scp_jp.api.member_management import UserUpdate

user_data = UserUpdate(name="更新されたユーザー名")
updated_user = await client.update_user(user_id=456, user_data=user_data)
```

### ユーザーの権限更新

```python
from scp_jp.api.member_management import UserPermissionUpdate

permission_data = UserPermissionUpdate(permission_level=PermissionLevel.ADMIN)
updated_user = await client.update_user_permission(
    user_id=456,
    permission_data=permission_data
)
```

### ユーザーの権限チェック

```python
has_permission = await client.check_user_permission(
    user_id=456,
    permission_level=PermissionLevel.ADMIN
)
```

## 合言葉管理 API

### 合言葉の作成

```python
from scp_jp.api.member_management import ApplicationPasswordCreate

password_data = ApplicationPasswordCreate(
    site_id=123,
    password="新しい合言葉",
    is_enabled=True
)
new_password = await client.create_application_password(password_data)
```

### 合言葉一覧の取得（フィルタリング付き）

```python
passwords = await client.get_application_passwords(
    site_id=123,
    is_enabled=True
)
```

### 合言葉の有効/無効の切り替え

```python
updated_password = await client.toggle_application_password(password_id=789)
```

### 合言葉の更新

```python
from scp_jp.api.member_management import ApplicationPasswordUpdate

password_data = ApplicationPasswordUpdate(password="更新された合言葉")
updated_password = await client.update_application_password(
    password_id=789,
    password_data=password_data
)
```

## 参加申請管理 API

### 参加申請一覧の取得（フィルタリング付き）

```python
requests = await client.get_application_requests(
    site_id=123,
    statuses=[Status.PENDING]
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
from scp_jp.api.member_management import SiteApplicationAccept

approval_data = SiteApplicationAccept(reviewer_id=456)
result = await client.approve_application_request(
    request_id=101,
    approval_data=approval_data
)
```

### 参加申請の拒否

```python
from scp_jp.api.member_management import SiteApplicationDecline, DeclineReasonType

decline_data = SiteApplicationDecline(
    reviewer_id=456,
    decline_reason_type=DeclineReasonType.INCORRECT_PASSWORD,
    decline_reason_detail="合言葉が不正確です"
)
result = await client.decline_application_request(
    request_id=101,
    decline_data=decline_data
)
```

## 公開エンドポイント API

### 公開パスワード（合言葉）の取得

```python
html_content = await client.get_public_password(
    site_id=123,
    user_id=456,
    user_name="ユーザー名"
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

## エラーハンドリング

APIクライアントは、エラーが発生した場合に `httpx.HTTPStatusError` 例外を発生させます。これをキャッチして適切に処理することができます。

```python
try:
    site = await client.get_site(site_id=999)
except httpx.HTTPStatusError as e:
    if e.response.status_code == 404:
        print("サイトが見つかりませんでした")
    else:
        print(f"APIエラー: {e}")
```

## 注意事項

- このクライアントは非同期APIを使用しているため、`await` キーワードまたは `asyncio.run()` を使用して実行する必要があります。
- API呼び出しにはヘッダーに有効なAPIキーが必要です。
- 一部のエンドポイント（公開パスワードの取得など）は認証を必要としません。