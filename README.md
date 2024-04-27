Certainly! Let's enhance the features section of your README with more details:

---

# Sells-Point Node with Express Server

Sells-Point is a platform where users can buy or sell used products easily. This repository contains the backend server built using Node.js and Express.

## Features

1. **Login and Registration System**:
   - Users can create accounts, log in, and register securely.
   - Passwords are hashed and stored securely.
   - authentication tokens are managed for user sessions.

2. **Update Profile**:
   - Users can update their profile information (e.g., name, email, date of birth).

3. **Create Sell Posts**:
   - Users can create posts to sell their products.
   - Each post includes details such as product name, price, and images.
   - Posts are stored in the database and associated with the user.

4. **Delete Own Posts**:
   - Users have the ability to delete their own posts.
   - Deleted posts are removed from the platform.

5. **Integrate Stripe for Payment Method**:
   - Stripe API is integrated for handling payments.
   - Users can securely make payments for purchased products.

6. **Image Upload**:
   - Users can upload images for their sell posts.
   - Images are stored on a cloud storage service (e.g., cloudinary).
   - Image URLs are associated with the respective posts.

7. **Role System (User and Admin)**:
   - Differentiates between user and admin roles.
   - Admins have additional privileges (e.g., managing user accounts, reviewing posts).
   - Admin credentials: Email: `admin@gmail.com`, Password: `abAB12!@`.

8. **MVVM Pattern**:
   - The project follows the Model-View-ViewModel architectural pattern.
   - Separation of concerns ensures maintainability and scalability.

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/tanvinpavel/sells-point.git
   ```

2. Navigate to the project directory:
   ```
   cd sells-point-main
   ```

3. Install dependencies:
   ```
   npm install
   ```

4. Run the server:
   ```
   npm start
   ```

## Usage

- Make sure you have MongoDB set up and running.
- Configure environment variables (e.g., database connection, Stripe API keys) in a `.env` file.