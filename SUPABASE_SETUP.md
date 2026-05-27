# 云端数据库配置

这个页面可以继续作为静态网页部署到 GitHub Pages，但数据需要放到 Supabase。

## 1. 创建 Supabase 项目

在 Supabase 新建一个项目，然后打开 SQL Editor。

## 2. 运行建表脚本

打开 `supabase-schema.sql`，先把这两行邮箱改成你们真实登录用的邮箱：

```sql
('zhaojun@example.com'),
('tao@example.com')
```

然后把整个 SQL 文件复制到 Supabase SQL Editor 里运行。

## 3. 创建两个登录账号

在 Supabase 的 Authentication 里，为这两个邮箱创建账号。也可以直接在网页上的“云端同步”区域注册。

如果 Supabase 开启了邮箱确认，需要先完成邮箱确认才能登录。

## 4. 填写网页配置

在 `index.html` 中找到：

```js
const cloudConfig = {
  supabaseUrl: "",
  supabaseAnonKey: ""
};
```

把 Supabase Project Settings > API 里的 Project URL 和 anon/public key 填进去：

```js
const cloudConfig = {
  supabaseUrl: "https://你的项目.supabase.co",
  supabaseAnonKey: "你的 anon public key"
};
```

不要填写 service_role key，静态网页里只能放 anon/public key。

## 5. 重新部署 Pages

把更新后的 `index.html` 和 `supabase-schema.sql` 一起提交到 Pages 仓库。

部署后，两个人都登录网页，就可以共享：

- 周末计划和历史
- 减肥计划表和体重曲线
- 记忆便签
- 私密相册

私密相册会先用相册密码在浏览器里加密，再上传到 Supabase Storage。即使在云端保存，也需要知道相册密码才能解密查看。
