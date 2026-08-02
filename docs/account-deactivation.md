# Account Deactivation

Self-service account deactivation is reversible soft deactivation.

When a user confirms deactivation with their password and exact email address, the app:

- sets `users.deactivated_at`;
- destroys all active sessions;
- sends `SecurityMailer.account_deactivated`;
- blocks future sign-in.

The starter does not physically delete account records. Products that need deletion should define retention, audit, billing, and legal rules first.
