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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker

PlasmaCore.Dialog {
    id: root
    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.Floating
    hideOnWindowDeactivate: true

    property int iconSize: units.iconSizes.huge
    property int cellSize: iconSize + theme.mSize(theme.defaultFont).height
        + (2 * units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))
    property bool searching: (searchField.text != "")

    onVisibleChanged: {
        if (!visible) {
            reset();
        } else {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
            requestActivate();
        }
    }

    onHeightChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onWidthChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onSearchingChanged: {
        if (searching) {
            pageList.model = runnerModel;
            paginationBar.model = runnerModel;
        } else {
            reset();
        }
    }

    function reset() {
        if (!searching) {
            pageList.model = rootModel.modelForRow(0);
            paginationBar.model = rootModel.modelForRow(0);
        }

        searchField.text = "";

        pageListScrollArea.focus = true;
        pageList.currentIndex = plasmoid.configuration.showFavoritesFirst ? 0 : 1;
        pageList.currentItem.itemGrid.currentIndex = -1;

        // Use positionViewAtIndex, to force an instant page switch
        // even if animations are enabled.
        pageList.positionViewAtIndex(pageList.currentIndex, ListView.Contain);
    }

    function popupPosition(width, height) {
        var screenAvail = plasmoid.availableScreenRect;
        var screenGeom = plasmoid.screenGeometry;
        //QtBug - QTBUG-64115
        var screen = Qt.rect(screenAvail.x + screenGeom.x,
                             screenAvail.y + screenGeom.y,
                             screenAvail.width,
                             screenAvail.height);

        var offset = units.gridUnit;

        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - height - offset;
        var appletTopLeft;
        var horizMidPoint;
        var vertMidPoint;

        if (plasmoid.configuration.showAtCenter) {
            horizMidPoint = screen.x + (screen.width / 2);
            vertMidPoint = screen.y + (screen.height / 2);
            x = horizMidPoint - width / 2;
            y = vertMidPoint - height / 2;
        } else if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
            horizMidPoint = screen.x + (screen.width / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = (appletTopLeft.x < horizMidPoint) ? screen.x + offset : (screen.x + screen.width) - width - offset;
            y = screen.height - height - offset - panelSvg.margins.top;
        } else if (plasmoid.location === PlasmaCore.Types.TopEdge) {
            horizMidPoint = screen.x + (screen.width / 2);
            var appletBottomLeft = parent.mapToGlobal(0, parent.height);
            x = (appletBottomLeft.x < horizMidPoint) ? screen.x + offset : (screen.x + screen.width) - width - offset;
            y = parent.height + panelSvg.margins.bottom + offset;
        } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
            vertMidPoint = screen.y + (screen.height / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = parent.width + panelSvg.margins.right + offset;
            y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset : (screen.y + screen.height) - height - offset;
        } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            vertMidPoint = screen.y + (screen.height / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = appletTopLeft.x - panelSvg.margins.left - offset - width;
            y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset : (screen.y + screen.height) - height - offset;
        }

        return Qt.point(x, y);
    }


    FocusScope {
        Layout.minimumWidth: (cellSize * 6) + (2 * units.largeSpacing)
        Layout.maximumWidth: (cellSize * 6) + (2 * units.largeSpacing)
        Layout.minimumHeight: (cellSize * 4) + searchField.height + paginationBar.height + (3 * units.largeSpacing)
        Layout.maximumHeight: (cellSize * 4) + searchField.height + paginationBar.height + (3 * units.largeSpacing)
        focus: true

    PlasmaExtras.Heading {
        id: heading
        level: 5
        text: i18n("Applications")
        anchors {
            left: parent.left
            leftMargin: units.largeSpacing
            top: parent.top
            topMargin: units.smallSpacing
        }
    }

    TextMetrics {
        id: headingMetrics
        font: heading.font
    }

    PlasmaComponents.Label {
        id: searchLabel
        text: i18n("Type to search...")
        opacity: 0.5
        anchors {
            left: parent.left
            leftMargin: (2 * units.largeSpacing + heading.width)
            right: parent.right
            rightMargin: units.largeSpacing
            baseline: heading.baseline
        }
    }
    
    PlasmaComponents.TextField {
        id: searchField
        placeholderText: i18n("Type to search...")
        clearButtonShown: true
        visible: false
        anchors {
            left: parent.left
            leftMargin: (2 * units.largeSpacing + heading.width)
            right: parent.right
            rightMargin: units.largeSpacing
            baseline: heading.baseline
        }
        
        onTextChanged: {
            if (visible == false) {
                visible = true;
                searchLabel.visible = false;
            }
            runnerModel.query = text;
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Down) {
                pageList.currentItem.itemGrid.focus = true;
                pageList.currentItem.itemGrid.currentIndex = 0;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (text != "" && pageList.currentItem.itemGrid.count > 0) {
                    pageList.currentItem.itemGrid.tryActivate(0, 0);
                    pageList.currentItem.itemGrid.model.trigger(0, "", null);
                    root.visible = false;
                }
            }
        }
        
        onEditingFinished: {
            if (text == "") {
                visible = false;
                searchLabel.visible = true;
            }
        }

        function backspace() {
            if (!root.visible) {
                return;
            }

            focus = true;
            text = text.slice(0, -1);
        }

        function appendText(newText) {
            if (!root.visible) {
                return;
            }

            focus = true;
            text = text + newText;
        }
    }

    PlasmaExtras.ScrollArea {
        id: pageListScrollArea
        frameVisible: false
        width: (cellSize * 6)
        focus: true
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        anchors {
            left: parent.left
            leftMargin: units.largeSpacing
            top: searchField.bottom
            topMargin: units.largeSpacing
            right: parent.right
            rightMargin: units.largeSpacing
            bottom: paginationBar.top
        }

        ListView {
            id: pageList
            anchors.fill: parent
            orientation: Qt.Horizontal
            snapMode: ListView.SnapOneItem
            cacheBuffer: (cellSize * 6) * count
            currentIndex: (searching || plasmoid.configuration.showFavoritesFirst) ? 0 : 1
            model: rootModel.modelForRow(0)


            /*   Animate scroll speed slider has values in range 150-550, and steps of 100.
             *   700 - value = animation speed in msec.
             *
             *   0: 150
             *   1: 250
             *   2: 350
             *   3: 450
             *   4: 550
             */
            highlightMoveDuration: (700 - plasmoid.configuration.animateScrollSpeed)

            onCurrentIndexChanged: {
                if (!plasmoid.configuration.animateScroll) {
                    positionViewAtIndex(currentIndex, ListView.Contain);
                }
            }

            onCurrentItemChanged: {
                if (!currentItem) {
                    return;
                }

                currentItem.itemGrid.focus = true;
            }

            onModelChanged: {
                currentIndex = (searching || plasmoid.configuration.showFavoritesFirst) ? 0 : 1;
            }

            onFlickingChanged: {
                if (!flicking) {
                    var pos = mapToItem(contentItem, root.width / 2, root.height / 2);
                    var itemIndex = indexAt(pos.x, pos.y);
                    currentIndex = itemIndex;
                }
            }

            function cycle() {
                enabled = false;
                enabled = true;
            }

            function activateNextPrev(next) {
                var newIndex;
                if (next) {
                    newIndex = pageList.currentIndex + 1;

                    if (newIndex === pageList.count) {
                        newIndex = plasmoid.configuration.wrapScroll ? 0 : pageList.currentIndex;
                    }
                } else {
                    newIndex = pageList.currentIndex - 1;

                    if (newIndex < 0) {
                        newIndex = plasmoid.configuration.wrapScroll ? pageList.count - 1 : pageList.currentIndex;
                    }
                }
                pageList.currentIndex = newIndex;
            }

            delegate: Item {
                width: cellSize * 6
                height: cellSize * 4

                property Item itemGrid: gridView

                ItemGridView {
                    id: gridView
                    anchors.fill: parent
                    cellWidth: cellSize
                    cellHeight: cellSize
                    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                    dragEnabled: (index == 0)
                    model: searching ? runnerModel.modelForRow(0) : rootModel.modelForRow(0).modelForRow(index)

                    onCurrentIndexChanged: {
                        if (currentIndex != -1 && !searching) {
                            pageListScrollArea.focus = true;
                            focus = true;
                        }
                    }

                    onCountChanged: {
                        if (searching && index == 0) {
                            currentIndex = 0;
                        }
                    }

                    onKeyNavUp: {
                        currentIndex = -1;
                        searchField.focus = true;
                    }

                    onKeyNavRight: {
                        var newIndex = pageList.currentIndex + 1;
                        var cRow = currentRow();

                        if (newIndex == pageList.count) {
                            newIndex = 0;
                        }

                        pageList.currentIndex = newIndex;
                        pageList.currentItem.itemGrid.tryActivate(cRow, 0);
                    }

                    onKeyNavLeft: {
                        var newIndex = pageList.currentIndex - 1;
                        var cRow = currentRow();

                        if (newIndex < 0) {
                            newIndex = (pageList.count - 1);
                        }

                        pageList.currentIndex = newIndex;
                        pageList.currentItem.itemGrid.tryActivate(cRow, 5);
                    }
                }

                Kicker.WheelInterceptor {
                    anchors.fill: parent
                    z: 1

                    property int wheelDelta: 0

                    function scrollByWheel(wheelDelta, eventDelta) {
                        // magic number 120 for common "one click"
                        // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                        wheelDelta += eventDelta;

                        var increment = 0;

                        while (wheelDelta >= 120) {
                            wheelDelta -= 120;
                            increment++;
                        }

                        while (wheelDelta <= -120) {
                            wheelDelta += 120;
                            increment--;
                        }

                        while (increment != 0) {
                            pageList.activateNextPrev(increment < 0);
                            increment += (increment < 0) ? 1 : -1;
                        }

                        return wheelDelta;
                    }

                    onWheelMoved: {
                        wheelDelta = scrollByWheel(wheelDelta, delta.y);
                    }
                }
            }
        }
    }

    ListView {
        id: paginationBar
        width: model.count * units.iconSizes.small
        height: units.iconSizes.small
        orientation: Qt.Horizontal
        model: rootModel.modelForRow(0)
        anchors {
            bottom: parent.bottom
            bottomMargin: units.largeSpacing
            horizontalCenter: parent.horizontalCenter
        }
        interactive: false

        delegate: Item {
            width: units.iconSizes.small
            height: width

            Rectangle {
                id: pageDelegate

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                width: parent.width / 2
                height: width

                property bool isCurrent: (pageList.currentIndex == index)

                radius: width / 2

                color: theme.textColor
                opacity: 0.5

                Behavior on width { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }
                Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }

                states: [
                    State {
                        when: pageDelegate.isCurrent
                        PropertyChanges { target: pageDelegate; width: parent.width - (units.smallSpacing * 2) }
                        PropertyChanges { target: pageDelegate; opacity: 0.8 }
                    }
                ]
            }

            MouseArea {
                anchors.fill: parent
                onClicked: pageList.currentIndex = index;

                property int wheelDelta: 0

                function scrollByWheel(wheelDelta, eventDelta) {
                    // magic number 120 for common "one click"
                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                    wheelDelta += eventDelta;

                    var increment = 0;

                    while (wheelDelta >= 120) {
                        wheelDelta -= 120;
                        increment++;
                    }

                    while (wheelDelta <= -120) {
                        wheelDelta += 120;
                        increment--;
                    }

                    while (increment != 0) {
                        pageList.activateNextPrev(increment < 0);
                        increment += (increment < 0) ? 1 : -1;
                    }

                    return wheelDelta;
                }

                onWheel: {
                    wheelDelta = scrollByWheel(wheelDelta, wheel.angleDelta.y);
                }
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;

            if (searching) {
                reset();
            } else {
                root.visible = false;
            }

            return;
        }

        if (searchField.focus) {
            return;
        }

        if (event.key === Qt.Key_Backspace) {
            event.accepted = true;
            searchField.backspace();
        } else if (event.text !== "") {
            event.accepted = true;
            searchField.appendText(event.text);
        }
    }

    }

    Component.onCompleted: {
        kicker.reset.connect(reset);
        dragHelper.dropped.connect(pageList.cycle);
    }
}
