/**
 * TrueVow DRAFT™ Desktop Application - Main Process
 * Electron main process for desktop document validation
 * 
 * ZERO-KNOWLEDGE ARCHITECTURE:
 * - Documents processed locally only
 * - Files never uploaded to servers
 * - Validation happens on user's device
 */

const { app, BrowserWindow, ipcMain, dialog, Menu, Tray, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const Store = require('electron-store');

// Initialize persistent storage
const store = new Store();

// Global references
let mainWindow = null;
let tray = null;

// App configuration
const APP_CONFIG = {
    name: 'TrueVow DRAFT',
    version: '1.0.0',
    width: 1024,
    height: 768,
    minWidth: 800,
    minHeight: 600
};

/**
 * Create main application window
 */
function createWindow() {
    mainWindow = new BrowserWindow({
        width: APP_CONFIG.width,
        height: APP_CONFIG.height,
        minWidth: APP_CONFIG.minWidth,
        minHeight: APP_CONFIG.minHeight,
        title: APP_CONFIG.name,
        icon: path.join(__dirname, 'assets/icon.png'),
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false,
            enableRemoteModule: true
        },
        autoHideMenuBar: false,
        backgroundColor: '#ffffff'
    });

    // Load the index.html
    mainWindow.loadFile('index.html');

    // Open DevTools in development mode
    if (process.argv.includes('--dev')) {
        mainWindow.webContents.openDevTools();
    }

    // Handle window close
    mainWindow.on('close', (event) => {
        if (!app.isQuitting) {
            event.preventDefault();
            mainWindow.hide();
        }
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    // Create application menu
    createApplicationMenu();

    // Create system tray
    createSystemTray();
}

/**
 * Create application menu
 */
function createApplicationMenu() {
    const template = [
        {
            label: 'File',
            submenu: [
                {
                    label: 'Open Document...',
                    accelerator: 'CmdOrCtrl+O',
                    click: () => {
                        mainWindow.webContents.send('menu-open-file');
                    }
                },
                {
                    type: 'separator'
                },
                {
                    label: 'Settings',
                    accelerator: 'CmdOrCtrl+,',
                    click: () => {
                        mainWindow.webContents.send('menu-open-settings');
                    }
                },
                {
                    type: 'separator'
                },
                {
                    label: 'Exit',
                    accelerator: 'CmdOrCtrl+Q',
                    click: () => {
                        app.isQuitting = true;
                        app.quit();
                    }
                }
            ]
        },
        {
            label: 'Edit',
            submenu: [
                { role: 'undo' },
                { role: 'redo' },
                { type: 'separator' },
                { role: 'cut' },
                { role: 'copy' },
                { role: 'paste' },
                { role: 'selectAll' }
            ]
        },
        {
            label: 'Validation',
            submenu: [
                {
                    label: 'Validate Current Document',
                    accelerator: 'CmdOrCtrl+V',
                    click: () => {
                        mainWindow.webContents.send('menu-validate');
                    }
                },
                {
                    type: 'separator'
                },
                {
                    label: 'Sync Rules',
                    accelerator: 'CmdOrCtrl+S',
                    click: () => {
                        mainWindow.webContents.send('menu-sync-rules');
                    }
                }
            ]
        },
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'forceReload' },
                { role: 'toggleDevTools' },
                { type: 'separator' },
                { role: 'resetZoom' },
                { role: 'zoomIn' },
                { role: 'zoomOut' },
                { type: 'separator' },
                { role: 'togglefullscreen' }
            ]
        },
        {
            label: 'Help',
            submenu: [
                {
                    label: 'Documentation',
                    click: () => {
                        shell.openExternal('https://docs.truevow.com/draft');
                    }
                },
                {
                    label: 'Report Issue',
                    click: () => {
                        shell.openExternal('https://github.com/truevow/draft/issues');
                    }
                },
                {
                    type: 'separator'
                },
                {
                    label: `About ${APP_CONFIG.name}`,
                    click: () => {
                        dialog.showMessageBox(mainWindow, {
                            type: 'info',
                            title: `About ${APP_CONFIG.name}`,
                            message: `${APP_CONFIG.name}`,
                            detail: `Version: ${APP_CONFIG.version}\n\nZero-knowledge legal document validator.\n\n© 2025 TrueVow`
                        });
                    }
                }
            ]
        }
    ];

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
}

/**
 * Create system tray
 */
function createSystemTray() {
    const iconPath = path.join(__dirname, 'assets/tray-icon.png');
    
    tray = new Tray(iconPath);
    
    const contextMenu = Menu.buildFromTemplate([
        {
            label: 'Show App',
            click: () => {
                mainWindow.show();
            }
        },
        {
            label: 'Validate Document',
            click: () => {
                mainWindow.show();
                mainWindow.webContents.send('menu-open-file');
            }
        },
        {
            type: 'separator'
        },
        {
            label: 'Sync Rules',
            click: () => {
                mainWindow.webContents.send('menu-sync-rules');
            }
        },
        {
            type: 'separator'
        },
        {
            label: 'Quit',
            click: () => {
                app.isQuitting = true;
                app.quit();
            }
        }
    ]);
    
    tray.setContextMenu(contextMenu);
    tray.setToolTip(APP_CONFIG.name);
    
    tray.on('click', () => {
        mainWindow.show();
    });
}

/**
 * App lifecycle events
 */
app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    } else {
        mainWindow.show();
    }
});

app.on('before-quit', () => {
    app.isQuitting = true;
});

// ============================================================================
// IPC HANDLERS
// ============================================================================

/**
 * Open file dialog
 */
ipcMain.handle('open-file-dialog', async () => {
    const result = await dialog.showOpenDialog(mainWindow, {
        properties: ['openFile'],
        filters: [
            { name: 'Documents', extensions: ['docx', 'doc', 'pdf', 'txt'] },
            { name: 'Word Documents', extensions: ['docx', 'doc'] },
            { name: 'PDF Files', extensions: ['pdf'] },
            { name: 'Text Files', extensions: ['txt'] },
            { name: 'All Files', extensions: ['*'] }
        ]
    });
    
    return result;
});

/**
 * Read file content
 */
ipcMain.handle('read-file', async (event, filePath) => {
    try {
        const ext = path.extname(filePath).toLowerCase();
        
        if (ext === '.txt') {
            // Read text file
            const content = fs.readFileSync(filePath, 'utf-8');
            return { success: true, content, type: 'text' };
        } else if (ext === '.docx') {
            // Read Word document
            const mammoth = require('mammoth');
            const result = await mammoth.extractRawText({ path: filePath });
            return { success: true, content: result.value, type: 'docx' };
        } else if (ext === '.pdf') {
            // Read PDF
            const pdfParse = require('pdf-parse');
            const dataBuffer = fs.readFileSync(filePath);
            const data = await pdfParse(dataBuffer);
            return { success: true, content: data.text, type: 'pdf' };
        } else {
            throw new Error('Unsupported file type');
        }
    } catch (error) {
        return { success: false, error: error.message };
    }
});

/**
 * Get stored settings
 */
ipcMain.handle('get-settings', () => {
    return {
        // UPDATED: DRAFT is now integrated into Tenant App (not separate service)
        apiUrl: store.get('apiUrl', 'http://localhost:8000/api/v1'),
        apiKey: store.get('apiKey', ''),
        autoSync: store.get('autoSync', true),
        syncInterval: store.get('syncInterval', 24),
        analyticsEnabled: store.get('analyticsEnabled', true),
        defaultPracticeArea: store.get('defaultPracticeArea', ''),
        defaultJurisdiction: store.get('defaultJurisdiction', '')
    };
});

/**
 * Save settings
 */
ipcMain.handle('save-settings', (event, settings) => {
    try {
        Object.keys(settings).forEach(key => {
            store.set(key, settings[key]);
        });
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

/**
 * Get cached rules
 */
ipcMain.handle('get-cached-rules', () => {
    return store.get('cachedRules', null);
});

/**
 * Save cached rules
 */
ipcMain.handle('save-cached-rules', (event, rules) => {
    try {
        store.set('cachedRules', rules);
        store.set('lastSync', new Date().toISOString());
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

/**
 * Get last sync time
 */
ipcMain.handle('get-last-sync', () => {
    return store.get('lastSync', null);
});

/**
 * Show notification
 */
ipcMain.handle('show-notification', (event, options) => {
    if (mainWindow) {
        mainWindow.webContents.send('show-notification', options);
    }
});

console.log(`${APP_CONFIG.name} v${APP_CONFIG.version} started`);

