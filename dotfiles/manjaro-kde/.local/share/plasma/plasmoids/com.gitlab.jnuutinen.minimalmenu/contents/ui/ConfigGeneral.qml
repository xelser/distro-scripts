/*
*  Copyright 2018 Juha Nuutinen <juha.nuutinen@protonmail.com>
*
*  This file is a part of Minimal Menu.
*  Minimal Menu is forked from Simple menu (https://github.com/KDE/plasma-simplemenu)
*
*  Takeoff is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Takeoff is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_useCustomButtonImage: useCustomButtonImage.checked
    property alias cfg_customButtonImage: customButtonImage.text

    property alias cfg_appNameFormat: appNameFormat.currentIndex
    property alias cfg_showFavoritesFirst: showFavoritesFirst.checked
    property alias cfg_wrapScroll: wrapScroll.checked

    property alias cfg_animateScroll: animateScroll.checked
    property alias cfg_animateScrollSpeed: animateScrollSpeed.value
    property alias cfg_showAtCenter: showAtCenter.checked

    property alias cfg_useExtraRunners: useExtraRunners.checked
    
    ColumnLayout {
        GroupBox {
            Layout.fillWidth: true

            title: i18n("Icon")

            flat: true

            RowLayout {
                CheckBox {
                    id: useCustomButtonImage

                    text: i18n("Use custom image:")
                }

                TextField {
                    id: customButtonImage

                    enabled: useCustomButtonImage.checked

                    Layout.fillWidth: true
                }

                Button {
                    iconName: "document-open"

                    enabled: useCustomButtonImage.checked

                    onClicked: {
                        imagePicker.folder = systemSettings.picturesLocation();
                        imagePicker.open();
                    }
                }

                FileDialog {
                    id: imagePicker

                    title: i18n("Choose an image")

                    selectFolder: false
                    selectMultiple: false

                    nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

                    onFileUrlChanged: {
                        customButtonImage.text = fileUrl;
                    }
                }

                Kicker.SystemSettings {
                    id: systemSettings
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")

            flat: true

            ColumnLayout {
                RowLayout {
                    Label {
                        text: i18n("Show applications as:")
                    }

                    ComboBox {
                        id: appNameFormat

                        Layout.fillWidth: true

                        model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
                    }
                }
                
                CheckBox {
                    id: showFavoritesFirst
                    
                    text: i18n("Show favorites first")
                }
                
                CheckBox {
                    id: wrapScroll
                    
                    text: i18n("Page switching wraps around")
                }

                CheckBox {
                    id: showAtCenter

                    text: i18n("Position launcher at the center of the screen")
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Effects")

            flat: true

            ColumnLayout {
                CheckBox {
                    id: animateScroll

                    text: i18n("Animate page switching")
                }

                RowLayout {
                    visible: animateScroll.checked
                    Label {
                        text: i18n("Slow")
                    }

                    Slider {
                        id: animateScrollSpeed

                        maximumValue: 550

                        minimumValue: 150

                        stepSize: 100

                        tickmarksEnabled: true

                        wheelEnabled: false
                    }

                    Label {
                        text: i18n("Fast")
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Search")

            flat: true

            ColumnLayout {
                CheckBox {
                    id: useExtraRunners

                    text: i18n("Expand search to bookmarks, files and emails")
                }
            }
        }
    }
}
