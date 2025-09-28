# Security Policy

## Supported Versions

We currently support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in NexusEvent, please report it responsibly:

### 🔒 Private Disclosure
Please **DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please email us privately at: **i.flint.lab@gmail.com**

### 📧 What to include
When reporting a vulnerability, please include:

1. **Description** of the vulnerability
2. **Steps to reproduce** the issue
3. **Potential impact** assessment
4. **Suggested fix** (if you have one)
5. **Your contact information** for follow-up

### ⏱️ Response Time
- We will acknowledge receipt of your vulnerability report within **48 hours**
- We will provide a detailed response within **7 days**
- We will work with you to understand and resolve the issue promptly

### 🏆 Recognition
We appreciate responsible disclosure and will:
- Credit you in our security advisory (if you wish)
- Keep you informed throughout the resolution process
- Notify you when the fix is released

## Security Best Practices

When using NexusEvent:

### 🔐 Webhook URLs
- Never commit webhook URLs to version control
- Use environment variables for sensitive configuration
- Validate webhook URLs before use
- Use HTTPS-only webhook endpoints

### 🛡️ Input Validation
- Always validate user input before creating messages
- Be cautious with user-generated content in message fields
- Sanitize URLs and content appropriately

### 🔄 Updates
- Keep your NexusEvent SDK updated to the latest version
- Monitor our security advisories
- Subscribe to release notifications

## Scope

This security policy applies to:
- NexusEvent Flutter SDK
- NexusEvent JavaScript SDK
- Official examples and documentation
- CI/CD configurations

## Out of Scope
- Third-party integrations using our SDK
- Issues in dependencies (please report to upstream projects)
- General support questions (use GitHub Issues instead)

Thank you for helping keep NexusEvent secure! 🛡️