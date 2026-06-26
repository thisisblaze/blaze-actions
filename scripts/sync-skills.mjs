#!/usr/bin/env node
/**
 * Cross-platform script to sync skills from .agents/skills to .claude/skills
 * This replaces the broken symlinks on Windows.
 */
import fs from 'fs';
import path from 'path';

const sourceDir = path.join(process.cwd(), '.agents', 'skills');
const targetDir = path.join(process.cwd(), '.claude', 'skills');

if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
}

// Ensure source exists
if (fs.existsSync(sourceDir)) {
    const skills = fs.readdirSync(sourceDir);
    skills.forEach(skill => {
        const sourcePath = path.join(sourceDir, skill);
        const targetPath = path.join(targetDir, skill);
        
        // Remove existing symlink or file if it exists
        if (fs.existsSync(targetPath) || fs.lstatSync(targetPath, {throwIfNoEntry: false})) {
            fs.rmSync(targetPath, { recursive: true, force: true });
        }
        
        // Copy directory or file
        if (fs.statSync(sourcePath).isDirectory()) {
            fs.cpSync(sourcePath, targetPath, { recursive: true });
        } else {
            fs.copyFileSync(sourcePath, targetPath);
        }
        console.log(`Synced skill: ${skill}`);
    });
    console.log('Skills sync complete.');
} else {
    console.warn('Source directory .agents/skills not found. Skipping sync.');
}
