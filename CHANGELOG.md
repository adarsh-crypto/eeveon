# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-16

### Added
- Initial release of EEveon CI/CD Pipeline
- CLI tool for managing deployment pipelines
- Automatic monitoring of GitHub repositories
- Support for `.deployignore` patterns
- Environment variable management with `.env` files
- Post-deployment hooks support
- Comprehensive logging system
- Multiple project support
- Systemd service integration
- Installation script with dependency checking

### Features
- Poll GitHub every 2 minutes (configurable)
- Automatic deployment on new commits
- rsync-based file synchronization
- Git-based version control integration
- Bash and Python implementation

### Documentation
- Complete README with examples
- Quick start guide
- Architecture documentation
- Troubleshooting guide
