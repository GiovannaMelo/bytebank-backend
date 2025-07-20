class User {
  constructor({ _id, username, email, password }) {
    this.username = username
    this.email = email
    this.password = password
    this.id = _id
  }

  isValid() {
    return this.username && this.email && this.password
  }
}

module.exports = User