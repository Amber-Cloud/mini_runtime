# DataAPI Architecture Decisions

## Multi-Tenant Database Design

We're using a **shared database with app_id columns** to separate data between different applications.

**Example:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  app_id VARCHAR NOT NULL  -- <- This separates the apps
);

SELECT * FROM users WHERE app_id = 'blog_app' AND id = 123;
```

## Why This Approach?

This is a **test assignment with time constraints**. We chose the simplest approach that demonstrates the API concepts without getting bogged down in complex database architecture.

**What this gets us:**
- Fast implementation and testing
- Focus on the actual API logic
- Clear demonstration of multi-tenancy via URL structure (`/app_id/endpoint`)

## Production Concerns

**This approach has serious limitations for real applications:**

- **Security Risk**: One bug could leak data between apps
- **Performance**: All apps compete for the same database resources  
- **Compliance**: GDPR/privacy laws often require complete data separation
- **Operations**: Can't backup, scale, or monitor apps independently

## Better Approach for Production

**Separate databases per application** would be ideal:

```
blog_app_database: users, articles, comments
shop_app_database: users, products, orders  
```

This gives complete isolation, independent scaling, and proper security boundaries.

## Implementation Trade-offs

For this assignment:

✅ **Fast development** - single migration setup  
✅ **Easy testing** - all data in one place  
✅ **Clear focus** - spend time on API logic, not database complexity  

❌ **Not production-ready** - would need significant changes for real deployment  
❌ **Security limitations** - only suitable for trusted test data

This decision prioritizes getting the API working quickly while acknowledging it's not how you'd build this for production.