# Wasfa 🍳

**Wasfa** is a modern Flutter recipe application that helps users discover delicious recipes, save their favorite meals, and organize ingredients through a personal shopping list.

The app uses **TheMealDB API** to provide recipes, categories, ingredients, instructions, and additional recipe sources.

## Features

* 🍽️ Discover random and delicious recipes
* 🔎 Search for recipes by name
* 🗂️ Browse recipes by category
* ❤️ Add and remove recipes from favorites
* 🕘 View recently opened recipes
* 🛒 Add recipe ingredients to a shopping list
* ✅ Mark shopping list items as completed
* 🗑️ Remove individual items or clear the entire shopping list
* 🌙 Light and dark mode
* 🔗 Open recipe preparation videos and original sources
* 🎨 Modern and responsive Material 3 UI
* ✨ Smooth animations and loading states
* 💾 Local data storage using Hive

## Screens

The application includes:

* Home
* Search
* Categories
* Category Meals
* Recipe Details
* Favorites
* Shopping List
* Settings
* Splash Screen

## Tech Stack

| Technology    | Usage                          |
| ------------- | ------------------------------ |
| Flutter       | Mobile application development |
| Dart          | Programming language           |
| TheMealDB API | Recipe data                    |
| Hive          | Local data storage             |
| HTTP          | API requests                   |
| URL Launcher  | Opening external links         |
| Material 3    | User interface                 |

## Project Structure

lib/
├── api_services/
│   └── meal_api_service.dart
│
├── models/
│   ├── category_model.dart
│   ├── meal_model.dart
│   └── shopping_item_model.dart
│
├── services/
│   ├── favorites_service.dart
│   ├── meal_service.dart
│   ├── recent_meal_service.dart
│   └── shopping_list_service.dart
│
├── screens/
│   ├── categories_screen.dart
│   ├── category_meals_screen.dart
│   ├── favorites_screen.dart
│   ├── home_screen.dart
│   ├── main_screen.dart
│   ├── recipe_details_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   ├── shopping_list_screen.dart
│   └── splash_screen.dart
│
├── widgets/
│   ├── build_error.dart
│   ├── build_loading.dart
│   ├── category_card.dart
│   ├── empty_state.dart
│   ├── favorite_button.dart
│   ├── horizontal_meal_card.dart
│   ├── ingredient_item.dart
│   ├── instruction_step.dart
│   ├── meal_card.dart
│   ├── recipe_info_chip.dart
│   ├── search_bar.dart
│   └── section_header.dart
│
├── theme/
│   └── app_theme.dart
│
└── main.dart

## Architecture

Wasfa follows a simple layered structure:

UI
│
├── Screens
│
├── Shared Widgets
│
├── Services
│
├── API Services
│
└── Models

### API Layer

`MealApiService` handles communication with TheMealDB API.

### Service Layer

Services handle application logic and local storage:

* `MealService`
* `FavoritesService`
* `RecentMealsService`
* `ShoppingListService`

### Model Layer

Models convert API and local data into strongly structured Dart objects.

### Widget Layer

Reusable widgets are used across multiple screens to keep the UI consistent and maintainable.

## Local Storage

Hive is used to store application data locally.

The application uses the following boxes:

favoriteMeals
recentMeals
shopping_list
settings
translations

This allows favorites, recently viewed recipes, shopping list items, and settings to remain available after restarting the application.

## Getting Started

### Requirements

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android Emulator or physical Android device

### Installation

Clone the repository:

git clone https://github.com/Khaledwaleed11/wasfa.git

Open the project:

cd wasfa

Install dependencies:

flutter pub get

Run the application:

flutter run

## Build APK

To generate a release APK:

flutter build apk --release

The APK will be generated in:

build/app/outputs/flutter-apk/app-release.apk

## API

Wasfa uses **TheMealDB** for recipe data.

The API provides:

* Random meals
* Recipe search
* Recipe details
* Categories
* Meals by category
* Meals by area
* Meals by ingredient

## Screenshots

![Home]

<img width="300" height="700" alt="wasfa_home" src="https://github.com/user-attachments/assets/fe3f52eb-0177-4cf6-a3e3-8d31514131c1" />

![Home2]
<img width="300" height="700" alt="wasfa_home2" src="https://github.com/user-attachments/assets/6e94d8dd-904b-48cf-8239-fbb4d0af9a04" />


![Search]

<img width="300" height="700" alt="wasfa_search" src="https://github.com/user-attachments/assets/aaa42fb2-e4e8-41dd-a749-a08852445cfd" />


![Categories]

<img width="300" height="700" alt="wasfa_categories" src="https://github.com/user-attachments/assets/2f9c5836-2513-4537-8c60-fc972e895fcf" />

![Categories2]

<img width="300" height="700" alt="wasfa_categories2" src="https://github.com/user-attachments/assets/62fdbc31-e93a-4926-852c-74f6bc29caec" />


![Recipe Details]

<img width="300" height="700" alt="wasga_recipe_detials" src="https://github.com/user-attachments/assets/e6a59595-bdc5-46d7-b227-b3be1fc78a4c" />

![Favorites]

<img width="300" height="700" alt="wasfa_favourites" src="https://github.com/user-attachments/assets/079693d1-7ac5-44cd-bd34-3ed117402ac0" />

![Shopping List]

<img width="300" height="700" alt="wasfa_shopping_list" src="https://github.com/user-attachments/assets/bd7f6cfd-38a5-4fda-83e8-5d7780a1afdd" />

![Settings]

<img width="300" height="700" alt="wasfa_setting" src="https://github.com/user-attachments/assets/aed2d8ad-4478-404d-aa65-8a809cc39ab6" />

## Future Improvements

Possible future improvements include:

* 🔐 User authentication
* ☁️ Cloud synchronization
* 🔔 Recipe notifications
* 🎥 Embedded cooking videos
* 🌐 Multiple language support
* ⭐ Recipe ratings
* 📝 Personal recipe creation
* 📤 Recipe sharing

## Author

**Khaled Waleed**

Flutter Developer

## License

This project is for educational and development purposes.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
