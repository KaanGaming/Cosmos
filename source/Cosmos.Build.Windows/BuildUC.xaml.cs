﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Indy.IL2CPU;
using System.Collections.ObjectModel;
using System.Windows.Threading;

namespace Cosmos.Build.Windows {

    public class BuildLogMessage {
		public LogSeverityEnum Severity { get; set; }
		public string Message { get; set; }
	}
	
    public class BuildLogMessages : ObservableCollection<BuildLogMessage> {
		public BuildLogMessages() { }
	}

    public partial class BuildUC : UserControl {
        public BuildUC() {
            InitializeComponent();
            Height = float.NaN;
            Width = float.NaN;
        }

        public bool Display(Builder aBuilder, DebugModeEnum aDebugMode, byte aComPort) {
            IEnumerable<BuildLogMessage> xMessages = new BuildLogMessage[0];
            aBuilder.PreventFreezing += PreventFreezing;
            aBuilder.DebugLog += DoDebugMessage;
            aBuilder.ProgressChanged += DoProgressMessage;
            //try {
                aBuilder.Compile(aDebugMode, aComPort);

                aBuilder.DebugLog -= DoDebugMessage;
                aBuilder.ProgressChanged -= DoProgressMessage;
            //} catch {
            //    return false;
            //}
            return true;
        }

		public void DoDebugMessage(LogSeverityEnum aSeverity, string aMessage) {
			if (aSeverity == LogSeverityEnum.Informational) {
				return;
			}
		}

        public void PreventFreezing() {
            var xFrame = new DispatcherFrame();
            Dispatcher.CurrentDispatcher.BeginInvoke(DispatcherPriority.Input, new DispatcherOperationCallback(delegate(object aParam)
            {
                xFrame.Continue = false;
                return null;
            }), null);
            Dispatcher.PushFrame(xFrame);
        }
        
        protected void ProgressMessageReceived(string aMsg) {
            listProgress.SelectedIndex = listProgress.Items.Add(aMsg);
            listProgress.ScrollIntoView(listProgress.Items[listProgress.SelectedIndex]);
        }
        
        public void DoProgressMessage(int aMax, int aCurrent, string aMessage) {
            var xAction = (Action)delegate() { 
                ProgressMessageReceived(aMessage); 
            };
            Dispatcher.BeginInvoke(DispatcherPriority.Input, xAction);
            PreventFreezing();
        }

    }
}
