cmake_minimum_required(VERSION 3.16)
project(Jeu_motus VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

# Liste des fichiers source C++
set(SOURCES
    main.cpp
    game.cpp
    dictionary.cpp
    timer.cpp
)

set(HEADERS
    game.h
    dictionary.h
    timer.h
)

# Liste des fichiers QML
set(QML_FILES
    Main.qml
    HomeScreen.qml
    GameScreen.qml
)

# Liste des ressources
set(RESOURCES
    dictionnaire.txt
)

qt_add_executable(appJeu_motus
    ${SOURCES}
    ${HEADERS}
)

qt_add_qml_module(appJeu_motus
    URI Jeu_motus
    VERSION 1.0
    QML_FILES ${QML_FILES}
    RESOURCES ${RESOURCES}
)

# Ajoutez le fichier QRC si nécessaire
qt_add_resources(appJeu_motus "qml_resources"
    PREFIX "/"
    FILES ${QML_FILES} ${RESOURCES}
)

# Copier le dictionnaire dans le répertoire de build
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/dictionnaire.txt
               ${CMAKE_CURRENT_BINARY_DIR}/dictionnaire.txt
               COPYONLY)

set_target_properties(appJeu_motus PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appJeu_motus
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appJeu_motus
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

