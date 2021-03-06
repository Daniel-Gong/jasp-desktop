//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//
import QtQuick			2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts	1.3 as L
import JASP.Controls	1.0

import JASP.Widgets		1.0
import JASP				1.0

AnalysisForm
{
	id					: form
	implicitWidth		: jaspTheme.formWidth - ( 2 * jaspTheme.formMargin )
	implicitHeight		: formContent.height + (jaspTheme.formMargin * 2)
	width				: implicitWidth
	height				: implicitHeight
	errorMessagesItem	: errorMessagesBox
	
	default property alias	content		: contentArea.children
	property alias	form				: form
	property bool	usesJaspResults		: true
	property int	majorVersion		: 1
	property int	minorVersion		: 0
	property bool	usesVariablesModel	: false
	property int	availableWidth		: form.width - 2 * jaspTheme.formMargin
	property var    analysis			: myAnalysis
	property var	backgroundForms		: backgroundFlickable
	property alias	columns				: contentArea.columns

	property int    plotHeight			: 320
	property int    plotWidth			: 480

	function getJASPControls(controls, item, deep)
	{
		for (var i = 0; i < item.children.length; ++i)
		{
			var child = item.children[i];

			if (child.objectName === "Section")
			{
				controls.push(child.button);
				getJASPControls(controls, child.childControlsArea, deep);
			}
			else if (child instanceof JASPControl)
			{
				if (child.activeFocusOnTab)
				{
					controls.push(child);
					if (child.childControlsArea && deep)
						getJASPControls(controls, child.childControlsArea, deep);
				}
				else
					getJASPControls(controls, child, deep);

			}
			else
				getJASPControls(controls, child, deep);
		}
	}

	MouseArea
	{
		z:				-5
		anchors.fill:	parent
		onClicked:		form.forceActiveFocus()
	}

	IntegerField { visible: false; name: "plotWidth";  value: plotWidth }
	IntegerField { visible: false; name: "plotHeight"; value: plotHeight }
	
	
	FocusScope
	{
		id:				formContent
		width:			parent.width
		height:			errorMessagesBox.height + contentArea.implicitHeight
		anchors
		{
			top:		form.top
			left:		form.left
		}
				
		Rectangle
		{
			property alias text:	errorMessagesText.text
			
			id:				errorMessagesBox
			objectName:		"errorMessagesBox"
			visible:		false
			color:			jaspTheme.errorMessagesBackgroundColor
			width:			parent.width
			height:			visible ? errorMessagesText.height : 0

			Text
			{
				id:					errorMessagesText
				anchors.centerIn:	parent
				padding:			5
				wrapMode:			Text.Wrap
				width:				parent.width - 10
				verticalAlignment:	Text.AlignVCenter
			}
		}
		
		GridLayout
		{
			id:				contentArea
			anchors.top:	errorMessagesBox.bottom
			width:			parent.width
		}
	}
	
	Timer
	{
		id:				bindingTimer
		running:		false
		repeat:			false
		interval:		0
		onTriggered:	formCompleted();
	}
	
	Component.onCompleted:	bindingTimer.start()
}
